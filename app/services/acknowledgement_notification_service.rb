class AcknowledgementNotificationService
  def execute(acknowledgement)
    return unless acknowledgement.target_user.push_notification_setting.acknowledged_notification_enabled

    @acknowledgement = acknowledgement
    alert = NotificationHelper.generate_alert_for_apn(
      title: "Message Acknowledged",
      body: acknowledged_body
    )
    non_aps_attributes = NotificationHelper.generate_non_aps_attributes(acknowledgement.acknowledeable, true)

    NotificationHelper.send_push_notification(acknowledgement.target_user, alert, non_aps_attributes)
    NotificationHelper.send_push_notification_gcm(
      acknowledgement.target_user,
      { title: "Message Acknowledged", body: acknowledged_body },
      non_aps_attributes)
  end

  def acknowledged_body
    message_text = if @acknowledgement.acknowledeable_type == "ChatMessage"
                     @acknowledgement.acknowledeable.message
                   elsif @acknowledgement.acknowledeable_type == "Engage::Message"
                     @acknowledgement.acknowledeable.body
                   end
    "#{@acknowledgement.user.name} has acknowedged your message, #{message_text || ''}."
  end
end
