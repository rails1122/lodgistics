class TaskItemCategorySerializer < TaskItemSerializer
  attributes :items

  def items
    object.items.reorder(:id).map { |ir| ActiveModelSerializers::SerializableResource.new(ir).as_json }
  end
end