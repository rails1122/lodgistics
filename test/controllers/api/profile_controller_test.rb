require 'test_helper'

describe Api::ProfileController do
  describe 'GET #show' do
    describe 'with authorized user' do
      let(:user) { create(:user) }
      let(:api_key) { auth_with_user(user) }
      let(:valid_request) {
        @request.headers['HTTP_AUTHORIZATION'] = api_key.access_token
        @request.headers['HTTP_PROPERTY_TOKEN'] = Property.current.token
        get :show, format: :json
      }

      it 'returns status 200' do
        valid_request
        assert_response :success
      end
    end

    describe 'with unauthorized user' do
      let(:user) { create(:user) }
      let(:invalid_request) {
        @request.headers['HTTP_AUTHORIZATION'] = 'invalid key'
        get :show,
            { format: :json }
      }

      it 'returns status 401' do
        invalid_request
        assert_response :unauthorized
      end
    end
  end

  describe 'PATCH #update' do
    describe 'with invalid attributes' do
      let(:user) { create(:user) }
      let(:api_key) { auth_with_user(user) }
      let(:invalid_request) {
        @request.headers['HTTP_AUTHORIZATION'] = api_key.access_token
        @request.headers['HTTP_PROPERTY_TOKEN'] = Property.current.token
        patch :update, format: :json, params: {
          user: {
            token: '',
            platform: 'unknown'
          }
        }
      }

      it 'shows error messages' do
        invalid_request
        assert_response 422
      end
    end

    describe 'with valid attributes' do
      let(:user) { create(:user) }
      let(:api_key) { auth_with_user(user) }
      let(:valid_request) {
        @request.headers['HTTP_AUTHORIZATION'] = api_key.access_token
        @request.headers['HTTP_PROPERTY_TOKEN'] = Property.current.token
        patch :update, format: :json, params: {
          user: {
            token: SecureRandom.hex,
            platform: 'ios'
          }
        }
      }

      it 'creates new device for user' do
        valid_request
        assert_response 200
        user.devices.count.must_equal 1
      end
    end
  end
end
