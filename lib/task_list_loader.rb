class TaskListLoader
  def initialize(filename)
    @filename = filename
  end

  def load_data!(properties = [])
    if properties.blank?
      properties = Property.all
    elsif properties.is_a?(Property)
      properties = [properties]
    end

    task_lists = YAML.load_file Rails.root.join('db', 'task_lists.yml')
    properties.each do |p|
      p.run_block do
        task_lists.each do |task_list_yml|
          name = task_list_yml[:task_list]
          description = task_list_yml[:description]
          notes = task_list_yml[:notes]

          task_list = TaskList.find_or_initialize_by(name: name)
          task_list.created_by = p.users.first
          task_list.description = description
          task_list.notes = notes

          task_list.save!

          task_list_yml[:assignables].each do |assignable|
            departments = assignable[:departments]
            roles = assignable[:roles]

            departments.each do |department|
              roles.each do |role|
                department_id = Department.find_or_create_by!(name: department).id
                role_id = Role.find_or_create_by!(name: role).id
                task_list.task_list_roles.assignable.find_or_create_by!(department_id: department_id, role_id: role_id)
              end
            end
          end

          task_list_yml[:reviewables].each do |reviewable|
            departments = reviewable[:departments]
            roles = reviewable[:roles]

            departments.each do |department|
              roles.each do |role|
                department_id = Department.find_or_create_by!(name: department).id
                role_id = Role.find_or_create_by!(name: role).id
                task_list.task_list_roles.reviewable.find_or_create_by!(department_id: department_id, role_id: role_id)
              end
            end
          end

          task_list_yml[:task_items].each_with_index do |task_items_yml, index|
            category = task_items_yml[:category]
            task_item_category = task_list.task_items.find_or_initialize_by(title: category)
            task_item_category.category_row_order_position = index
            task_item_category.save!

            task_items_yml[:items].each_with_index do |item, index|
              task_item = task_item_category.items.find_or_initialize_by(title: item)
              task_item.task_list = task_list
              task_item.item_row_order_position = index
              task_item.save!
            end
          end
        end
      end
    end
  end
end