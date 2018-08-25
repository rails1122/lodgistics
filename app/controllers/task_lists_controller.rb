class TaskListsController < ApplicationController
  add_breadcrumb I18n.t('.controllers.task_lists.index'), :task_lists_path

  def index
  end

  def new
    @task_list = TaskList.new
    @task_list.created_by = current_user
    @task_list.assignable_roles.build
    @task_list.reviewable_roles.build
  end

  def show
    @task_list = TaskList.find params[:id]
    @task_list_record = TaskListRecord.find params[:record_id]
    add_breadcrumb @task_list.name
  end

  def activities
    add_breadcrumb I18n.t('.controllers.task_lists.activities'), :activities_task_lists_path
  end

  def create
    @task_list = TaskList.new task_list_params.except(:attachment)
    @task_list.created_by = current_user

    if @task_list.save
      if task_list_params[:attachment]
        ChecklistIngestion.read_excel(@task_list, task_list_params[:attachment])
      end
      redirect_to :back, notice: 'New checklist is successfully created!'
    else
      @task_list.assignable_roles.build
      @task_list.reviewable_roles.build
      render :new, alert: 'Failed to create checklist'
    end
  end

  def setup
    add_breadcrumb I18n.t('.controllers.task_lists.setup')
  end

  def edit
    @task_list = TaskList.find params[:id]
    @task_list.assignable_roles.build
    @task_list.reviewable_roles.build
  end

  def update
    @task_list = TaskList.find params[:id]
    @task_list.updated_by = current_user

    if @task_list.update(task_list_params.except(:attachment))
      if task_list_params[:attachment]
        ChecklistIngestion.read_excel(@task_list, task_list_params[:attachment])
      end
      redirect_to :back, notice: 'Checklist is successfully updated!'
    else
      @task_list.assignable_roles.build
      @task_list.reviewable_roles.build
      render :edit, alert: 'Failed to update checklist'
    end
  end

  private

  def task_list_params
    (params[:task_list][:assignable_roles_attributes] || []).each do |key, value|
      value[:scope_type] = value[:scope_type].to_i
    end
    (params[:task_list][:reviewable_roles_attributes] || []).each do |key, value|
      value[:scope_type] = value[:scope_type].to_i
    end
    params.require(:task_list).permit(
        :name, :description, :notes, :attachment,
        assignable_roles_attributes: [:id, :role_id, :department_id, :scope_type, :_destroy],
        reviewable_roles_attributes: [:id, :role_id, :department_id, :scope_type, :_destroy]
    )
  end
end
