class TaskCategoryRecordSerializer < TaskItemRecordSerializer
  attribute :item_records

  def item_records
    object.item_records.map { |ir| ActiveModelSerializers::SerializableResource.new(ir).as_json }
  end
end