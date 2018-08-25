class TaskListRoleSerializer < ActiveModel::Serializer
  attributes :id, :department_id, :role_id, :scope_type
  attributes :department_name, :role_name

  def department_name
    object.department.name
  end

  def role_name
    object.role.name
  end
end