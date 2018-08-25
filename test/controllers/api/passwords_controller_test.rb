require 'test_helper'

describe Api::PasswordsController, 'POST #create' do
  describe 'with valid user attributes' do
    let(:user) { u = create(:user); u.current_property_role = Role.gm; u.save; u }

    it 'create reset password token on user' do
      assert(user.reset_password_token.nil?)
      assert(user.reset_password_sent_at.nil?)
      post :create, format: :json, params: { user: { email: user.email } }
      assert_response :success
      user.reload
      assert(user.reset_password_token.present?)
      assert(user.reset_password_sent_at.present?)
      json = JSON.parse(response.body)
      assert(json['email'] == user.email)
      assert(json['reset_password_sent_at'].present?)
    end

    it do
      post :create, format: :json, params: {
        user: { email: "unknown@address.com" }
      }
      assert_response 400
      json = JSON.parse(response.body)
      assert(json['error'] == 'email not found')
    end

    it 'email can be case in-sensitive' do
      email = user.email.upcase
      post :create, format: :json, params: {
        user: { email: email }
      }
      assert_response 200
      user.reload
      assert(user.reset_password_token.present?)
      assert(user.reset_password_sent_at.present?)
    end
  end
end

describe Api::PasswordsController, 'PUT #update' do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it 'empty password' do
    put :update, params: { user: { password: '', password_confirmation: '' } }
    assert_response 400
  end

  it 'short password' do
    put :update, params: {user: { password: '12345', password_confirmation: '' }}
    assert_response 400
  end

  it 'password confirmation not match' do
    put :update, params: { user: { password: '12345678', password_confirmation: '1234' } }
    assert_response 400
  end

  it 'should update password' do
    old_pwd = @user.encrypted_password
    put :update, params: { user: { password: '12345678', password_confirmation: '12345678' } }
    assert_response 200
    new_pwd = @user.reload.encrypted_password
    assert(old_pwd != new_pwd)
  end
end
