class TaskListDetailSerializer < TaskListSerializer
  has_many :task_list_roles

  attributes :categories

  def categories
    records = object.task_items.categories.order(:id)

    records.map { |cr|
      ActiveModelSerializers::SerializableResource.new(cr, {serializer: TaskItemCategorySerializer}).as_json
    }
  end
end