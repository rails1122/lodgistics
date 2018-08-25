object @task_list

attributes :task_list_id

node(:status) { |i| i.task_list_record(current_user).try(:status) }
node(:started_at) { |i| i.task_list_record(current_user).try(:started_at) }
