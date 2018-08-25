object @task_list

attributes :id, :property_id, :name, :description, :notes

node(:task_list_record_id) { |i| i.started_task_list_record(current_user).try(:id) }
node(:updated_at) { |i| i.started_task_list_record(current_user).try(:updated_at) }
node(:started_at) { |i| i.started_task_list_record(current_user).try(:started_at) }
