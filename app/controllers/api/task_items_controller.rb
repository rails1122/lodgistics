class Api::TaskItemsController < Api::BaseController

  before_action :set_resource, only: [:update, :destroy]

  def create
    # authorize TaskItem
    @task_item = TaskItem.new task_item_params
    @task_item.property = Property.current
    @task_item.save!

    serializer = @task_item.category? ? TaskItemCategorySerializer : TaskItemSerializer

    render json: @task_item, serializer: serializer
  end

  def update
    # authorize @task_item
    @task_item.update!(task_item_params)

    render json: @task_item
  end

  def destroy
    # authorize @task_item
    @task_item.destroy

    head 200
  end

  private

  def task_item_params
    params.require(:task_item).permit(:task_list_id, :title, :category_id)
  end

end