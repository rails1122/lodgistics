class RenameAllEnabledToEnabled < ActiveRecord::Migration[5.0]
  def change
    rename_column :push_notification_settings, :all_enabled, :enabled
  end
end
