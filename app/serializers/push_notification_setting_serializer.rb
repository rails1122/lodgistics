class PushNotificationSettingSerializer < ActiveModel::Serializer
  attributes :id, :user_id,
    :chat_message_notification_enabled, :feed_post_notification_enabled, :acknowledged_notification_enabled,
    :work_order_completed_notification_enabled, :work_order_assigned_notification_enabled,
    :unread_mention_notification_enabled, :unread_message_notification_enabled,
    :feed_broadcast_notification_enabled,
    :all_new_messages, :all_new_log_posts
end
