module Api::DepartmentsDoc
  extend BaseDoc

  namespace 'api'
  resource :departments

  doc_for :index do
    api :GET, '/departments', 'Get departments list for current property'

    description <<-EOS
      If successful, it returns a json list containing department information.

      department_obj contains:
        id: id
        name: name of role
        property_id: property_id
    EOS
  end

end
