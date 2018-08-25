class TaskListPolicy < ApplicationPolicy
  def all?
    true
  end

  def index?
    true
  end

  def show?
    assignable?
  end

  def start_resume?
    assignable?
  end

  def review?
    reviewable?
  end

  def complete?
    assignable?
  end

  def reset?
    assignable?
  end

  def destroy?
    true
  end

  private

  def get_task_list
    @record
  end

  def assignable?
    get_task_list.task_list_roles.assignable.where(role_id: @user.current_property_role.id, department_id: @user.department_ids).count > 0
  end

  def reviewable?
    get_task_list.task_list_roles.reviewable.where(role_id: @user.current_property_role.id, department_id: @user.department_ids).count > 0
  end

end
