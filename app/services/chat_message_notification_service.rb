class ChatMessageNotificationService
  def initialize(params)
    @chat_message = params[:chat_message]
    @current_user = params[:current_user]
    @non_aps_attributes = NotificationHelper.generate_non_aps_attributes(@chat_message)
    @additional_gcm_attributes = NotificationHelper.generate_additional_gcm_attributes(@chat_message)
  end

  def send_notifications
    send_notification_to_mentioned_users
    send_notifications_to_parent_message_sender
    send_notifications_to_chat_users
  end

  def notification_body_for_parent_message_sender
    name = chat_message.sender.try(:name)
    msg = chat_message.try(:message)
    "#{name} replied to your message:\n#{msg}"
  end

  def notification_body_for_mentioned_user
    name = chat_message.sender.try(:name)
    mentioned_user_names_with_at_sign = chat_message.mentioned_users.map { |i| "@#{i.name}" }.join(" ")
    msg = chat_message.try(:message)
    "#{name} mentioned you:\n#{mentioned_user_names_with_at_sign} #{msg}"
  end

  def notification_title_for_mentioned_user
    "You were mentioned"
  end

  def notification_title_for_parent_message_sender
    "New reply on your chat message"
  end

  private

  attr_reader :chat_message, :current_user, :non_aps_attributes, :additional_gcm_attributes

  def send_notifications_to_chat_users
    target_users = chat_message.chat.users - [ chat_message.sender ] - chat_message.mentioned_users
    return if target_users.blank?
    body = "#{chat_message.sender.try(:name)} messaged:\n#{chat_message.try(:message)}"
    title = "New chat message"
    alert = NotificationHelper.generate_alert_for_apn(body: body, title: title)
    target_users.each do |u|
      next unless u.push_notification_setting&.enabled?
      next unless u.push_notification_setting.all_new_messages

      NotificationHelper.send_push_notification(u, alert, non_aps_attributes)
      NotificationHelper.send_push_notification_gcm(u, { body: body, title: title }, additional_gcm_attributes)
    end
  end

  def send_notifications_to_parent_message_sender
    return if chat_message.responding_to_chat_message.blank?
    notified_user = chat_message.responding_to_chat_message.try(:sender)
    return if notified_user == current_user
    return unless notified_user.push_notification_setting&.enabled?
    return unless notified_user.push_notification_setting.chat_message_notification_enabled

    body = notification_body_for_parent_message_sender
    title = notification_title_for_parent_message_sender
    alert = NotificationHelper.generate_alert_for_apn(body: body, title: title)
    NotificationHelper.send_push_notification(notified_user, alert, non_aps_attributes)
    NotificationHelper.send_push_notification_gcm(notified_user, { body: body, title: title }, additional_gcm_attributes)
  end

  def send_notification_to_mentioned_users
    return if chat_message.mentioned_users.blank?

    body = notification_body_for_mentioned_user
    title = notification_title_for_mentioned_user
    alert = NotificationHelper.generate_alert_for_apn(body: body, title: title)
    chat_message.mentioned_users.each do |notified_user|
      next unless notified_user.push_notification_setting&.enabled?
      next unless notified_user.push_notification_setting.chat_message_notification_enabled
      NotificationHelper.send_push_notification(notified_user, alert, non_aps_attributes)
      NotificationHelper.send_push_notification_gcm(notified_user, { body: body, title: title }, additional_gcm_attributes)
    end
  end

end
