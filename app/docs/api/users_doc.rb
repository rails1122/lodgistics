module Api::UsersDoc
  extend BaseDoc

  namespace 'api'
  resource :users

  doc_for :multi_invite do
    api :POST, '/users/multi_invite', 'Invite new user - new user will be created if not existing. if user exists (e.g. created by admin), then invitiation will be sent.'
    error 401, 'Unauthorized'
    error 422, "Unable to create entity (e.g. validation failed)"
    error 500, "Server Error"
    param 'users[]', Array, of: Hash, desc: "users parameter - e.g. ?users[0][phone_number]=123-1234&users[1][phone_number]=222-3333", required: true

    description <<-EOS
      If successful, it returns an object containing user objects in 'users' key

      User object contains:
        id: user id
        name: user full name
        email: email
        phone_number: phone_number
    EOS
  end

  doc_for :invite do
    api :POST, '/users/invite', 'Invite new user - new user will be created if not existing. if user exists (e.g. created by admin), then invitiation will be sent.'
    error 401, 'Unauthorized'
    error 422, "Unable to create entity (e.g. validation failed)"
    error 500, "Server Error"
    param :user, Hash, desc: 'user parameter', required: true do
      param :phone_number, String, desc: 'phone number', required: true
      param :property_token, String, desc: 'property token'
      param :name, String, desc: 'full name'
      param :email, String, desc: 'email'
      param :role_id, Integer, desc: 'role id'
      param :department_id, Integer, desc: 'department id'
    end

    description <<-EOS
      If successful, it returns a user json object with following fields

      User object contains:
        id: user id
        name: user full name
        email: email
        phone_number: phone_number
    EOS
  end

  doc_for :index do
    api :GET, '/users', 'Get hotel users'
    description <<-EOS
      If successful, it returns list of <tt>user</tt> objects with status <tt>200</tt>.

      User object contains:
        id: Integer
        name: User Name
        title: User Title
        email: User Email
        username: Username
        avatar_img_url: User avatar img url
        avatar: User avatar
        departments: Department list with id and name
        role: Current hotel role
    EOS
  end

  doc_for :show do
    api :GET, '/users/:id', 'Get user info'
    description <<-EOS
      If successful, it returns <tt>user</tt> object.

      User object contains:
        id: Integer
        name: User Name
        title: User Title
        email: User Email
        username: Username
        phone_number: phone number
        avatar_img_url: User avatar img url
        departments: Department list with id and name
        role: Current hotel role name
        role_id: Current role id
    EOS
  end

  doc_for :update do
    api :PUT, '/users/:id', 'Update user info'
    description <<-EOS
      If successful, it returns updated <tt>user</tt> object.

      User object contains:
        id: Integer
        name: User Name
        title: User Title
        email: User Email
        username: Username
        phone_number: phone number
        avatar_img_url: User avatar img url
        departments: Department list with id and name
        role: Current hotel role name
        role_id: Current role id
    EOS
    param :id, Integer, required: true
    param :user, Hash, required: true do
      param :name, String, desc: 'name of user'
      param :title, String, desc: 'title of user'
      param :phone_number, String, desc: 'phone number'
      param :avatar_img_url, String, desc: 'url for uploaded avatar img'
      param :role_id, Integer, desc: 'role id'
      param :department_ids, Array, of: Integer, desc: 'department ids'
    end
  end

  doc_for :confirm do
    api :PUT, '/users/:id/confirm', 'Activate user'
    description <<-EOS
      If successful, it returns updated <tt>user</tt> object.

      User object contains:
        id: Integer
        name: User Name
        title: User Title
        phone_number: phone number
        avatar_img_url: User avatar img url
    EOS
    param :id, Integer, required: true
    param :user, Hash, required: true do
      param :name, String, desc: 'name of user'
      param :title, String, desc: 'title of user'
      param :phone_number, String, desc: 'phone number'
      param :avatar_img_url, String, desc: 'url for uploaded avatar img'
    end
  end

  doc_for :request_confirm do
    api :GET, '/users/request_confirm', 'Get user details with confiramtion token'
    description <<-EOS
      If successful, it returns <tt>user</tt> object.

      Example format: /users/request_confirm?confiramtion_token=<token>
    EOS

    param :confirmation_token, String, required: true
  end

  doc_for :roles_and_departments do
    api :GET, '/users/:id/roles_and_departments', 'Get roles and departments list for user'
    description <<-EOS
      If successful, it returns a json object with roles and departmenst list
        {
          'roles' => [ role_obj, ...],
          'departmenst' => [ department_obj, ...],
        }

      role_obj contains:
        id: id
        name: name of role

      department_obj contains:
        id: id
        name: name of role
        property_id: property_id
    EOS
  end


end
