require 'test_helper'

describe Api::PropertiesController, "GET #index" do
  describe 'when admin user' do
    before do
      create_user_for_property(Role.admin)
      @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
      @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    end

    it do
      get :index, format: :json
      assert_response 200
      json = JSON.parse(response.body)
      assert(json.size == 2)
      item = json.first
      assert(item.keys.sort == ['id', 'name', 'street_address', 'state', 'zip_code', 'city', 'time_zone', 'token'].sort)
    end
  end

  describe 'when non admin user' do
    before do
      create_user_for_property
      @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
      @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    end

    it do
      get :index, format: :json
      assert_response 401
    end
  end
end

describe Api::PropertiesController, "POST #create" do
  describe 'when guest user' do
    it do
      @last_count = Property.count
      property_param = { name: 'New Property' }
      post :create, format: :json, params: { property: property_param }
      assert_response 200
      assert(Property.count == @last_count + 1)
    end
  end

  describe 'when trying to create with duplicate address' do
    before do
      @property = create(:property, name: 'Property Name', street_address: '300 Regina Street')
    end

    it 'should fail on duplicate name' do
      property_param = { name: 'Property Name', street_address: '300 Regina Street' }
      post :create, format: :json, params: { property: property_param }
      assert_response 422
    end

    it 'should pass on different name' do
      property_param = { name: 'Different Name', street_address: '300 Regina Street' }
      post :create, format: :json, params: { property: property_param }
      assert_response 200
    end
  end

  describe 'when admin user' do
    before do
      create_user_for_property(Role.admin)
      @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
      @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
      @last_count = Property.count
    end

    it 'should create a new property' do
      property_param = { name: 'New Property' }
      post :create, format: :json, params: { property: property_param }
      assert_response 200
      assert(Property.count == @last_count + 1)
    end

    it do
      property_param = { name: 'New Property' }
      post :create, format: :json, params: { property: property_param }
      assert_response 200
      json = JSON.parse(response.body)
      assert(json.keys.sort == [ 'new_user_created', 'invitation_sent', 'message' ].sort)
      assert(json['new_user_created'] == false)
      assert(json['invitation_sent'] == false)
      assert(json['message'] == '')
    end

    describe 'when user parameter is given' do
      it 'should create a user and should not send an inviation' do
        user_param = { name: 'New User', email: 'abc@email.com', phone_number: '123-1234' }
        property_param = { name: 'New Property' }
        last_join_invite_count = JoinInvitation.count
        last_user_count = User.count
        post :create, format: :json, params: { property: property_param, user: user_param }
        assert_response 200
        last_user = User.last
        assert(last_user.phone_number == '123-1234')
        assert(last_user.name == 'New User')
        assert(last_user.email == 'abc@email.com')
        assert(Property.count == @last_count + 1)
        assert(User.count == last_user_count + 1)
        assert(JoinInvitation.count == last_join_invite_count)

        json = JSON.parse(response.body)
        assert(json.keys.sort == [ 'new_user_created', 'invitation_sent', 'message' ].sort)
        assert(json['new_user_created'] == true)
        assert(json['invitation_sent'] == false)
        assert(json['message'] == 'New User Created. Please check your email to activate')
      end
    end

    describe 'when user parameter is given, and that user is found in the database' do
      before do
        @user = create(:user, email: 'abc@email.com')
      end

      it 'should not create a new user and should send an inviation' do
        user_param = { name: 'New User', email: 'abc@email.com' }
        property_param = { name: 'New Property' }
        last_join_invite_count = JoinInvitation.count
        last_user_count = User.count
        post :create, format: :json, params: { property: property_param, user: user_param }
        assert_response 200
        assert(Property.count == @last_count + 1)
        assert(User.count == last_user_count)
        assert(JoinInvitation.count == last_join_invite_count + 1)

        json = JSON.parse(response.body)
        assert(json.keys.sort == [ 'new_user_created', 'invitation_sent', 'message' ].sort)
        assert(json['new_user_created'] == false)
        assert(json['invitation_sent'] == true)
        assert(json['message'] == 'Invitation Sent. Please check your email to accept invitation')
      end
    end
  end
end


