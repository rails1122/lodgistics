module Api::ProfileDoc
  extend BaseDoc

  namespace 'api'
  resource :profile

  doc_for :show do
    api :GET, '/profile', 'Get user profile.'
    description <<-EOS
      If successful, it returns a <tt>user</tt> object with status <tt>200</tt>.
      User object contains <tt>email</tt>, <tt>name</tt> right now.

      If unsuccessful, it returns an errors hash with status <tt>400</tt>.
    EOS
  end

  doc_for :update do
    api :PATCH, '/profile', 'Update user profile.'
    param :user, Hash, required: true do
      param :token,    String
      param :platform, %w(ios android)
      param :enabled, [true, false]
    end
  end
end