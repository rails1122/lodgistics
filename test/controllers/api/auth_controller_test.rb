require 'test_helper'

describe Api::AuthController do
  describe 'POST #create' do
    describe 'with unconfirmed user' do
      let(:user) { create(:user, confirmed_at: nil) }
      let(:valid_request) {
        post :create, format: :json, params: { user: { email: user.email, password: user.password } }
      }

      it 'does not create an api' do
        valid_request
        assert_response :unauthorized
        ApiKey.count.must_equal 0
      end
    end

    describe 'with valid attributes' do
      let(:user) { u = create(:user); u.current_property_role = Role.gm; u.save; u }

      it 'finds or creates an api_key' do
        post :create, format: :json, params: { user: { email: user.email, password: user.password } }
        assert_response :success
        assert(user.reload.api_key.present?)
      end

      it 'can login with username' do
        post :create, format: :json, params: { user: { email: user.username, password: user.password } }
        assert_response :success
        assert(user.reload.api_key.present?)
      end

      it 'can validate user with case insensitive email param' do
        post :create, format: :json, params: { user: { email: user.email.upcase, password: user.password } }
        assert_response :success
        assert(user.reload.api_key.present?)
      end
    end

    describe 'when device info is given' do
      let(:user) { create(:user) }
      let(:device_token) { SecureRandom.hex }
      let(:device_platform) { 'ios' }
      let(:valid_request) {
        user.current_property_role = Role.gm
        user.save
        post :create, format: :json, params: {
          user: {
            email: user.email,
            password: user.password,
            device_token: device_token,
            device_platform: device_platform
          }
        }
      }

      it 'creates a device record' do
        valid_request
        assert_response :success
        Device.count.must_equal 1
        d = Device.last
        assert(d.token == device_token)
        assert(d.platform == device_platform)
      end

      it 'make requests twice with same device info wil only create one device' do
        valid_request
        assert_response :success
        Device.count.must_equal 1
        valid_request
        Device.count.must_equal 1
      end

      it 'makes another request with different device token with same device_platform should replace old device token' do
        valid_request
        assert_response :success
        assert(user.reload.devices.length == 1)
        Device.count.must_equal 1
        old_device_token = user.devices.first.token
        another_device_token = SecureRandom.hex
        post :create, format: :json, params: {
          user: {
            email: user.email,
            password: user.password,
            device_token: another_device_token,
            device_platform: device_platform
          }
        }
        assert_response :success
        Device.count.must_equal 1
        assert(user.reload.devices.length == 1)
        assert(user.devices.first.token != old_device_token)
        assert(user.devices.first.token == another_device_token)
      end

      it 'makes another request with different device token with different device_platform should create another device' do
        valid_request
        assert_response :success
        assert(user.reload.devices.length == 1)
        Device.count.must_equal 1
        old_device_token = user.devices.first.token
        another_device_token = SecureRandom.hex
        post :create, format: :json, params: {
          user: {
            email: user.email,
            password: user.password,
            device_token: another_device_token,
            device_platform: 'android'
          }
        }
        assert_response :success
        Device.count.must_equal 2
        assert(user.reload.devices.length == 2)
        tokens = user.devices.map(&:token)
        assert_includes(tokens, old_device_token)
        assert_includes(tokens, another_device_token)
      end

    end

    describe "when device is already with another user" do
      let(:user) { create(:user) }
      let(:another_user) { create(:user) }
      let(:device_with_another_user) { create(:device, user: another_user) }
      let(:valid_request) {
        user.current_property_role = Role.gm
        user.save
        post :create, format: :json, params: {
          user: {
            email: user.email,
            password: user.password,
            device_token: device_with_another_user.token,
            device_platform: device_with_another_user.platform
          }
        }
      }

      before do
        device_with_another_user
        Device.count.must_equal 1
        assert(another_user.devices.length == 1)
        assert(user.devices.length == 0)
      end

      it "should remove another user's device" do
        valid_request
        assert_response :success
        assert(another_user.reload.devices.length == 0)
        assert(user.reload.devices.length == 1)
        Device.count.must_equal 1
      end
    end

    describe 'with invalid attributes' do
      let(:invalid_request) {
        post :create, format: :json, params: {
          user: { email: 'bademail', password: '123' }
        }
      }

      it 'does not create an api_key' do
        invalid_request
        assert_response :unauthorized
        ApiKey.count.must_equal 0
      end
    end
  end
end
