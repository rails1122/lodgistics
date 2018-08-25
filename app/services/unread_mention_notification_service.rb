class UnreadMentionNotificationService
  def execute(user_id)
    user = User.find(user_id)
    return unless user.push_notification_setting.unread_mention_notification_enabled
    unread_mentions = user.mentions&.not_checked
    return if unread_mentions.empty?

    unread_mentions.group_by(&:property_id).each do |property_id, mentions|
      property = Property.find(property_id)

      if mentions.count.positive?
        alert = NotificationHelper.generate_alert_for_apn(
          title: "",
          body: mentioned_messages_body(mentions.count, property.name)
        )
        non_aps_attributes = {
          type: {
             name: "unchecked_mentions",
             property_token: property.token
           }
        }
        NotificationHelper.send_push_notification(user, alert, non_aps_attributes)
        NotificationHelper.send_push_notification_gcm(
          user,
          { title: "", body: mentioned_messages_body(mentions.count, property.name) },
          non_aps_attributes)
      end
    end
  end

  private

  def mentioned_messages_body(chats_count, property_name)
    "You have been mentioned #{chats_count} time#{chats_count == 1 ? "" : "s"} in #{property_name}."\
    " Check these posts and messages soon!"
  end
end
