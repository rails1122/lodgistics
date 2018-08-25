class Api::TaskItemRecordsController < Api::BaseController
  include TaskItemRecordsDoc

  before_action :set_resource, only: [:complete, :reset]

  def complete
    authorize @task_item_record.task_list_record.task_list

    if (params[:category] == 'yes') != @task_item_record.category?
      render json: {error: 'Category option is not correct'}, status: :unprocessable_entity
      return
    end

    @task_item_record.complete!(current_user, task_item_complete_params)
    serializer = @task_item_record.category? ? TaskCategoryRecordSerializer : TaskItemRecordSerializer

    render json: @task_item_record, serializer: serializer
  end

  def reset
    authorize @task_item_record.task_list_record.task_list

    if (params[:category] == 'yes') != @task_item_record.category?
      render json: {error: 'Category option is not correct'}, status: :unprocessable_entity
      return
    end

    @task_item_record.reset!(current_user)

    serializer = @task_item_record.category? ? TaskCategoryRecordSerializer : TaskItemRecordSerializer

    render json: @task_item_record, serializer: serializer
  end

  private

  def task_item_complete_params
    params.require(:task_item_record).permit(:comment, :status)
  end
end