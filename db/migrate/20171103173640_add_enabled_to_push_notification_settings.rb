class AddEnabledToPushNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :push_notification_settings, :chat_message_notification_enabled, :boolean, default: true
    add_column :push_notification_settings, :feed_post_notification_enabled, :boolean, default: true
    add_column :push_notification_settings, :acknowledged_notification_enabled, :boolean, default: true
    add_column :push_notification_settings, :work_order_completed_notification_enabled, :boolean, default: true
    add_column :push_notification_settings, :work_order_assigned_notification_enabled, :boolean, default: true
    add_column :push_notification_settings, :unread_mention_notification_enabled, :boolean, default: true
    add_column :push_notification_settings, :unread_message_notification_enabled, :boolean, default: true
  end
end
