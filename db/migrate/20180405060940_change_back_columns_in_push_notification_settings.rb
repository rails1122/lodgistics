class ChangeBackColumnsInPushNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    rename_column :push_notification_settings, :mentioned_in_chat, :chat_message_notification_enabled
    rename_column :push_notification_settings, :mentioned_in_log_post, :feed_post_notification_enabled
    rename_column :push_notification_settings, :acknowledgement, :acknowledged_notification_enabled
    rename_column :push_notification_settings, :work_order_completed, :work_order_completed_notification_enabled
    rename_column :push_notification_settings, :work_order_assigned, :work_order_assigned_notification_enabled
    rename_column :push_notification_settings, :unread_mentions, :unread_mention_notification_enabled
    rename_column :push_notification_settings, :unread_messages, :unread_message_notification_enabled
    rename_column :push_notification_settings, :broadcasted_log_posts, :feed_broadcast_notification_enabled
  end
end
