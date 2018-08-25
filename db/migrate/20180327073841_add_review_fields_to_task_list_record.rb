class AddReviewFieldsToTaskListRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :task_list_records, :reviewed_at, :datetime
    add_column :task_list_records, :reviewed_by_id, :integer

    add_index :task_list_records, :reviewed_by_id
  end
end
