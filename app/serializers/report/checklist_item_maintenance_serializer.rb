class Report::ChecklistItemMaintenanceSerializer < ActiveModel::Serializer
  attributes :id, :comment, :checklist_item_title

  def checklist_item_title
    object.maintenance_checklist_item.name
  end
end