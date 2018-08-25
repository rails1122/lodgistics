module Api::PushNotificationSettingsDoc
  extend BaseDoc

  namespace 'api'
  resource :push_notification_settings

  doc_for :index do
    api :GET, '/push_notification_settings', 'Get push notification settings for current user'

    description <<-EOS
      If successful, it returns a json object containing push notification setting.

      push_notification_setting obj contains:
        id: id of push_notification_setting
        user_id: current user id
        enabled: Enable/Disable all notifications
        chat_message_notification_enabled: chat message notification enabled
        feed_post_notification_enabled: feed post notification enabled
        acknowledged_notification_enabled: acknowledged notification enabled
        work_order_completed_notification_enabled: work order complete notification enabled
        work_order_assigned_notification_enabled: work order assignment notification enabled
        unread_mention_notification_enabled: unread mention notification enabled
        unread_message_notification_enabled: unread message notification enabled
        all_new_messages:
        all_new_log_posts:
    EOS
  end

  doc_for :update do
    api :PUT, '/push_notification_settings', 'update push notification settings for current user'
    param :push_notification_setting, Hash, required: true do
      param :enabled, [true, false]
      param :chat_message_notification_enabled, [ true, false ]
      param :feed_post_notification_enabled, [ true, false ]
      param :acknowledged_notification_enabled, [ true, false ]
      param :work_order_completed_notification_enabled, [ true, false ]
      param :work_order_assigned_notification_enabled, [ true, false ]
      param :unread_mention_notification_enabled, [ true, false ]
      param :unread_message_notification_enabled, [ true, false ]
      param :all_new_messages, [ true, false ]
      param :all_new_log_posts, [ true, false ]
    end

    error 500, "Server Error"

    description <<-EOS
      If successful, it returns a json object containing push notification setting.

      push_notification_setting obj contains:
        id: id of push_notification_setting
        user_id: current user id
        enabled: enable/disable all notifications
        chat_message_notification_enabled: chat message notification enabled
        feed_post_notification_enabled: feed post notification enabled
        acknowledged_notification_enabled: acknowledged notification enabled
        work_order_completed_notification_enabled: work order complete notification enabled
        work_order_assigned_notification_enabled: work order assignment notification enabled
        unread_mention_notification_enabled: unread mention notification enabled
        unread_message_notification_enabled: unread message notification enabled
        all_new_messages:
        all_new_log_posts:
    EOS
  end

end
