class ChangeColumnsInPushNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    rename_column :push_notification_settings, :chat_message_notification_enabled, :mentioned_in_chat
    rename_column :push_notification_settings, :feed_post_notification_enabled, :mentioned_in_log_post
    rename_column :push_notification_settings, :acknowledged_notification_enabled, :acknowledgement
    rename_column :push_notification_settings, :work_order_completed_notification_enabled, :work_order_completed
    rename_column :push_notification_settings, :work_order_assigned_notification_enabled, :work_order_assigned
    rename_column :push_notification_settings, :unread_mention_notification_enabled, :unread_mentions
    rename_column :push_notification_settings, :unread_message_notification_enabled, :unread_messages
    rename_column :push_notification_settings, :feed_broadcast_notification_enabled, :broadcasted_log_posts
  end
end
