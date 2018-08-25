module Api::RolesDoc
  extend BaseDoc

  namespace 'api'
  resource :roles

  doc_for :index do
    api :GET, '/roles', 'Get roles list'

    description <<-EOS
      If successful, it returns a json list containing role information.

      role_obj contains:
        id: id
        name: name of role
    EOS
  end

end
