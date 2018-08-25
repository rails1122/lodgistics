class ChangeCompletedAtToFinishedAt < ActiveRecord::Migration[5.0]
  def change
    rename_column :task_list_records, :completed_at, :finished_at
    rename_column :task_list_records, :completed_by_id, :finished_by_id
  end
end
