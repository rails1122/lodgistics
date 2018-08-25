class Api::TaskListRecordsController < Api::BaseController
  include TaskListRecordsDoc
  serialization_scope :view_context

  before_action :set_resource, only: [:show, :finish, :review]

  def show
    authorize @task_list_record

    render json: @task_list_record
  end

  def finish
    authorize @task_list_record

    @task_list_record.finish!(current_user, params)
    TaskListRecordNotificationService.new(task_list_record: @task_list_record, current_user: current_user).send_notifications

    render json: @task_list_record, serializer: TaskListRecordSerializer
  end

  def review
    authorize @task_list_record

    if params[:status] == 'reviewed'
      @task_list_record.update!(
          reviewed_by_id: current_user.id,
          reviewer_notes: params[:notes],
          reviewed_at: Time.current,
          status: TaskListRecord.statuses[:reviewed]
      )
    else
      @task_list_record.update!(
          reviewer_notes: params[:notes]
      )
    end

    render json: @task_list_record, serializer: TaskListReviewSerializer
  end
end
