class AddDataToInAppNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :in_app_notifications, :data, :jsonb
    remove_column :in_app_notifications, :message, :text
    remove_column :in_app_notifications, :action, :string
  end
end
