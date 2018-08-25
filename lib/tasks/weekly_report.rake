namespace :weekly_report do
  desc "Generate weekly report"
	task generate_weekly_report: :environment do
		num_weeks = 3
		result = {}
		Property.all.each do |p|
			h = {
				work_order_count: Maintenance::WorkOrder.unscoped.where(property_id: p.id).group_by_week(:created_at, last: num_weeks).count,
				closed_work_order_count: Maintenance::WorkOrder.unscoped.where(property_id: p.id).closed.group_by_week(:created_at, last: num_weeks).count,
				feed_post_count: Engage::Message.unscoped.where(property_id: p.id).group_by_week(:created_at, last: num_weeks).count,
				chat_message_count: ChatMessage.unscoped.where(property_id: p.id).group_by_week(:created_at, last: num_weeks).count,
				task_list_record_count: TaskListRecord.unscoped.where(property_id: p.id).group_by_week(:created_at, last: num_weeks).count,
				finished_task_list_record_count: TaskListRecord.unscoped.where(property_id: p.id).finished.group_by_week(:created_at, last: num_weeks).count,
				checklist_item_maintenance_count: Maintenance::ChecklistItemMaintenance.unscoped.where(property_id: p.id).group_by_week(:created_at, last: num_weeks).count,
				checklist_item_count: Maintenance::ChecklistItem.unscoped.where(property_id: p.id).group_by_week(:created_at, last: num_weeks).count,
			}
			result[p.id] = h
		end
		puts result
  end
end
