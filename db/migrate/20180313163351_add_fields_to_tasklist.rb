class AddFieldsToTasklist < ActiveRecord::Migration[5.0]
  def change
    add_column :task_lists, :notes, :text
    rename_column :task_lists, :deleted_at, :inactivated_at
    add_column :task_lists, :inactivated_by_id, :integer

    add_index :task_lists, :inactivated_by_id
  end
end
