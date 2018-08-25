class UnreadMessageNotificationService
  def execute(user)
    return unless user.push_notification_setting.unread_message_notification_enabled
    unread_messages = user.unread_messages
    return if unread_messages.empty?

    unread_messages.pluck(:property_id).uniq.each do |property_id|
      property = Property.find(property_id)

      groups = user.unread_group_messages.where(property_id: property_id)&.group_by(&:chat_id)
      if groups.count.positive?
        group_alert = NotificationHelper.generate_alert_for_apn(
          title: "",
          body: group_messages_body(groups, property.name)
        )
        non_aps_attributes = {
          type: {
            name: "group_unread_messages",
            property_token: property.token
          }
        }
        NotificationHelper.send_push_notification(user, group_alert, non_aps_attributes)
        NotificationHelper.send_push_notification_gcm(
          user,
          { title: '', body: group_messages_body(groups, property.name) },
          non_aps_attributes
        )
      end

      privates = user.unread_private_messages.where(property_id: property_id)&.group_by(&:chat_id)
      if privates.count.positive?
        private_alert = NotificationHelper.generate_alert_for_apn(
          title: "",
          body: private_messages_body(privates, property.name)
        )
        non_aps_attributes = {
          type: {
            name: "private_unread_messages",
            property_token: property.token
          }
        }
        NotificationHelper.send_push_notification(user, private_alert, non_aps_attributes)
        NotificationHelper.send_push_notification_gcm(
          user,
          { title: '', body: private_messages_body(privates, property.name) },
          non_aps_attributes
        )
      end
    end
  end

  private

  def group_messages_body(groups, property_name)
    group_unread_messages_count = groups.map{ |g| g.last.count }.reduce(:+)
    "You have #{group_unread_messages_count} unread message"\
    "#{group_unread_messages_count == 1 ? "" : "s"} in "\
    "#{groups.count} group#{groups.count == 1 ? "" : "s"} at #{property_name}. Check them soon!"
  end

  def private_messages_body(privates, property_name)
    private_unread_messages_count = privates.map{ |p| p.last.count }.reduce(:+)
    "You have #{private_unread_messages_count} unread direct "\
    "message#{private_unread_messages_count == 1 ? "" : "s"} from "\
    "#{privates.count} of your colleague#{privates.count == 1 ? "" : "s"} at #{property_name}."\
    "Check them soon!"
  end
end
