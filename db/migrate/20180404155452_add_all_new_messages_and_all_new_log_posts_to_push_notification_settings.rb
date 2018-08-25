class AddAllNewMessagesAndAllNewLogPostsToPushNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :push_notification_settings, :all_new_messages, :boolean, default: true
    add_column :push_notification_settings, :all_new_log_posts, :boolean, default: true
  end
end
