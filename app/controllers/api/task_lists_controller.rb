class Api::TaskListsController < Api::BaseController
  include TaskListsDoc
  serialization_scope :view_context

  before_action :set_resource, only: [:show, :start_resume, :destroy]

  def all
    authorize TaskList
    @task_lists = TaskList.includes(
      :created_by, :updated_by, task_list_roles: [:department, :role]
    ).order(:id)

    render json: @task_lists, each_serializer: TaskListDetailSerializer
  end

  def index
    authorize TaskList
    @task_lists = get_assignable_task_lists
  end

  def activities
    limit = params[:limit] || 10
    finished_at = params[:finished_after] && DateTime.parse(params[:finished_after])

    roles = TaskListRole.where(role_id: current_user.current_property_role.id, department_id: current_user.department_ids)
    task_lists = TaskList.where(id: roles.pluck(:task_list_id))
    task_list_records = TaskListRecord.where(task_list_id: task_lists.map(&:id)).not_started.finished_after(finished_at).order(finished_at: :desc).limit(limit)
    result = task_list_records.map { |i| TaskListActivitySerializer.new(i, scope: view_context).as_json }
    render json: result
  end

  def show
    authorize @task_list
  end

  def start_resume
    authorize @task_list

    @record = @task_list.start_resume!(current_user, {task_list_record_id: params[:task_list_record_id]})

    if @record
      render json: @record, serializer: TaskListRecordSerializer
    else
      render json: {error: 'TaskListRecord id is incorrect.'}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task_list
    @task_list.destroy

    head 200
  end

  private

  def get_assignable_task_lists
    task_lists = TaskList.active
    roles = TaskListRole.assignable.where(role_id: current_user.current_property_role.id, department_id: current_user.department_ids)
    task_lists.where(id: roles.pluck(:task_list_id)).order(:id)
  end

  def get_reviewable_task_lists
    task_lists = TaskList.active
    roles = TaskListRole.reviewable.where(role_id: current_user.current_property_role.id, department_id: current_user.department_ids)
    task_lists.where(id: roles.pluck(:task_list_id)).order(:id)
  end
end
