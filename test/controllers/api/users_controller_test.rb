require 'test_helper'

describe Api::UsersController, "GET #index" do
  before do
    create_user_for_property(Role.user)
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @inactive_user = create(:user, deleted_at: 1.day.ago)
  end

  it "should have all user fields" do
    get :index, format: :json
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.first.symbolize_keys.keys.sort == [:avatar, :avatar_img_url, :departments, :email, :id, :name, :role, :role_id, :title, :username, :is_system_user].sort)
  end

  it 'should not include inactive users' do
    get :index, format: :json
    assert_response 200
    json = JSON.parse(response.body)
    ids = json.map { |i| i['id'] }
    refute_includes(ids, @inactive_user.id)
    assert_includes(ids, @user.id)
    assert_includes(ids, User.lodgistics_bot_user.id)
  end
end

describe Api::UsersController, "GET #show" do
  before do
    create_user_for_property(Role.user)
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_user = create(:user)
  end

  it "" do
    get :show, params: { format: :json, id: @user.id }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.symbolize_keys.keys.sort == [:id, :name, :email, :title, :username, :departments, :role, :avatar_img_url, :phone_number, :role_id, :is_system_user, :push_notification_enabled].sort)
  end

  it "cannot see someone else's user info" do
    get :show, params: { format: :json, id: @another_user.id }
    assert_response 401
  end
end

describe Api::UsersController, "PUT #update" do
  before do
    create_user_for_property(Role.user)
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_user = create(:user)
  end

  it "" do
    put :update, params: { format: :json, id: @user.id, user: { name: 'new name', title: 'new title', phone_number: '123-1234', avatar_img_url: 'http://via.placeholder.com/350x350' } }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.symbolize_keys.keys.sort == [:id, :name, :email, :title, :username, :departments, :role, :avatar_img_url, :phone_number, :role_id, :is_system_user].sort)
    @user.reload
    assert(@user.name == 'new name')
    assert(@user.title == 'new title')
    assert(@user.phone_number == '123-1234')

    user_role_record = UserRole.unscoped.find_by(property_id: @property.id, user_id: @user.id)
    assert(user_role_record.title == 'new title')

    assert(json['role'] == 'User')
    assert(json['role'] == @user.current_property_role&.name)
  end

  it 'should be able to update role' do
    assert(@user.roles.first.id == Role.user.id)
    put :update, params: { format: :json, id: @user.id, user: { name: 'new name', role_id: Role.gm.id } }
    assert_response 200
    @user.reload
    assert(@user.roles.first.id == Role.gm.id)
    json = JSON.parse(response.body)
    assert(json['role'] == 'General Manager')
    assert(json['role'] == @user.current_property_role&.name)
  end

  it 'should update departments' do
    another_department = create(:department, property_id: @property.id)
    put :update, params: { format: :json, id: @user.id, user: { name: 'new name', department_ids: [ another_department.id ] } }
    assert_response 200
    @user.reload
    assert(@user.departments.pluck(:id).sort == [ another_department.id ])
    json = JSON.parse(response.body)
    departments = json['departments']
    assert(departments[0]['id'] == another_department.id)
    assert(departments[0]['name'] == another_department.name)
  end

  it 'cannot update username, email, or order_approval_limit' do
    old_username = @user.username
    old_email = @user.email
    old_order_approval_limit = @user.order_approval_limit
    put :update, params: { format: :json, id: @user.id, user: { username: 'new username', email: 'new@email.com', order_approval_limit: '1.0' } }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.symbolize_keys.keys.sort == [:id, :name, :email, :title, :username, :departments, :role, :avatar_img_url, :phone_number, :role_id, :is_system_user].sort)
    @user.reload
    assert(@user.username == old_username)
    assert(@user.email == old_email)
    assert(@user.order_approval_limit == old_order_approval_limit)
  end

  # TODO : can a user update someone else's user info?
  it "cannot update another user's info" do
    put :update, params: { format: :json, id: @another_user.id, user: { name: 'new name', title: 'new title', phone_number: '123-1234' } }
    assert_response 401
  end
end

describe Api::UsersController, "GET #roles_and_departments" do
  before do
    create_user_for_property(Role.user)
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_user = create(:user)
  end

  it "" do
    get :roles_and_departments, params: { format: :json, id: @user.id }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json['roles'].count == Role.count)
  end

  it 'should only list departments for current property' do
    another_property = create(:property)
    dept_in_another_property = create(:department, property_id: another_property.id)
    dept_in_current_property = create(:department, property_id: @property.id)

    get :roles_and_departments, params: { format: :json, id: @user.id }
    json = JSON.parse(response.body)
    ids = json['departments'].map { |i| i['id'] }
    assert_includes(ids, dept_in_current_property.id)
    refute_includes(ids, dept_in_another_property.id)
  end
end

describe Api::UsersController, "POST #create" do
  describe 'when admin user' do
    before do
      create_user_for_property(Role.admin)
      @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
      @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    end

    it 'should create a new property' do
      post :create, format: :json, params: { user: { name: 'New User' } }
      assert_response 200
    end
  end
end

describe Api::UsersController, "POST #invite" do
  describe 'when admin user' do
    before do
      create_user_for_property(Role.admin)
      @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
      @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    end

    describe 'when no property token is given' do
      let(:new_email) { 'abc@email.com' }

      it 'should not create a user or join invitation' do
        user_param = { name: 'New User', email: new_email }
        post :invite, format: :json, params: { user: user_param }
        assert_response 422
      end
    end

    describe 'when there exists a user with given email' do
      let(:existing_email) { @user.email }

      it 'check json response' do
        user_param = { email: existing_email, property_token: @property.token }
        post :invite, format: :json, params: { user: user_param }
        json = JSON.parse(response.body)
        assert(json.keys.sort == ['id', 'name', 'email', 'phone_number'].sort)
      end

      it 'should create a join invitation instead of creating a user' do
        user_param = { email: existing_email, property_token: @property.token }
        assert_difference 'User.count', 0 do
          assert_difference 'JoinInvitation.count', 1 do
            post :invite, format: :json, params: { user: user_param }
            assert_response 200
          end
        end
      end
    end


    describe 'when there is no user with given email' do
      let(:new_email) { 'abc@email.com' }

      it 'should create a user record, but no invitation record' do
        user_param = { name: 'New User', email: new_email, property_token: @property.token }
        assert_difference 'User.count', 1 do
          assert_difference 'JoinInvitation.count', 0 do
            post :invite, format: :json, params: { user: user_param }
            assert_response 200
          end
        end
      end

      it 'should set temporary name' do
        user_param = { email: new_email, property_token: @property.token }
        assert_difference 'User.count', 1 do
          post :invite, format: :json, params: { user: user_param }
          assert_response 200
        end
        last_user = User.last
        assert(last_user.name == "First & Last Name")
      end
    end

    describe 'when phone_number is given instead of email' do
      it 'should create a user record, but no invitation record' do
        role_id = Role.admin.id
        department_id = Department.first.id
        user_param = { phone_number: '123-1234', property_token: @property.token, role_id: Role.admin.id, department_id: department_id }
        assert_difference 'User.count', 1 do
          assert_difference 'JoinInvitation.count', 0 do
            post :invite, format: :json, params: { user: user_param }
            assert_response 200
          end
        end
        last_user = User.last
        assert(last_user.name == "First & Last Name")
        assert(last_user.role_ids == [ role_id ])
        assert(last_user.department_ids == [ department_id ])
      end
    end

    describe 'when multiple users are given' do
      it 'should create multiple user record, but no invitation record' do
        #role_id = Role.admin.id
        department_id = Department.first.id
        user_param_1 = { phone_number: '123-1234', property_token: @property.token, role_id: Role.admin.id, department_id: department_id }
        user_param_2 = { phone_number: '123-1235', property_token: @property.token, role_id: Role.admin.id, department_id: department_id }
        assert_difference 'User.count', 2 do
          assert_difference 'JoinInvitation.count', 0 do
            post :multi_invite, format: :json, params: { users: [ user_param_1, user_param_2 ] }
            assert_response 200
          end
        end

        json = JSON.parse(response.body)
        assert(json['users'].size == 2)
        assert(json['users'].first.keys.sort == ['id', 'name', 'email', 'phone_number'].sort)
      end
    end
  end
end

describe Api::UsersController, "PUT #confirm" do
  before do
    create_user_for_property(Role.admin)
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @user_param = { phone_number: '123-1234', property_token: @property.token, role_id: Role.admin.id, department_id: Department.first.id }
    @confirm_param = {title: 'Confirmed User', name: 'Confirmed Name', avatar_img_url: 'http://via.placeholder.com/350x350', password: 'password', password_confirmation: 'password'}
  end

  it 'should confirm invited user' do
    post :invite, format: :json, params: {user: @user_param}
    user_id = api_response["id"]

    @confirm_param[:password] = 'incorrect-password'

    put :confirm, format: :json, params: {id: user_id, user: @confirm_param}
    response.status.must_equal 400

    @confirm_param[:password] = 'password'
    put :confirm, format: :json, params: {id: user_id, user: @confirm_param}

    user = User.find user_id
    user.confirmed?.must_equal true
    user.name.must_equal 'Confirmed Name'
    user.current_property_user_role.title.must_equal 'Confirmed User'
  end
end
