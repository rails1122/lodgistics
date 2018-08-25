object @work_order

attributes :id, :property_id, :description, :priority, :status, :due_to_date, :assigned_to_id,
           :maintainable_type, :maintainable_id, :opened_by_user_id, :created_at, :updated_at,
           :closed_by_user_id, :first_img_url, :second_img_url, :location_detail, :closed_at, :opened_at,
           :maintenance_checklist_item_id, :other_maintainable_location

node(:work_order_url) do |i|
  i.resource_url
end

node(:closed) do |i|
  i.closed?
end

node(:maintainable_type) do |i|
  i.maintainable_type.gsub('Maintenance::', '') if i.maintainable_type
end

node(:maintenance_checklist_item_id) do |wo|
  wo.checklist_item_maintenance&.maintenance_checklist_item_id
end