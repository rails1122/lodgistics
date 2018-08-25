class ChatNotificationService
  def initialize(params)
    @chat = params[:chat]
    @current_user = params[:current_user]
  end

  def send_notifications
    send_notification_to_chat_users
  end

  def notification_body_for_chat_users
    creator_name = chat.user.try(:name)
    chat_name = chat.try(:name)
    if chat.is_private
      "#{creator_name} started a private chat"
    else
      "#{creator_name} added you to a chat #{chat_name}"
    end
  end

  def notification_title
    "You were added to a chat"
  end

  def non_aps_attributes
    {
      type: {
        name: "group_create",
        property_token: chat.property&.token,
        detail: {
          chat_id: chat.id
        }
      }
    }
  end

  private

  attr_reader :chat, :current_user

  def send_notification_to_chat_users
    chat_users = chat.users - [ current_user ]
    return if chat_users.blank?
    return if chat.is_private

    body = notification_body_for_chat_users
    title = notification_title
    alert = NotificationHelper.generate_alert_for_apn(body: body, title: title)
    chat_users.each do |notified_user|
      next unless notified_user.push_notification_setting&.enabled?
      next unless notified_user.push_notification_setting.try(:chat_message_notification_enabled)
      NotificationHelper.send_push_notification(notified_user, alert, non_aps_attributes)
      NotificationHelper.send_push_notification_gcm(notified_user, { body: body, title: title}, non_aps_attributes)
    end
  end

end
