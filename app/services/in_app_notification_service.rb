class InAppNotificationService
  def permission_updated(recipient_user_id, property_id)
    n = InAppNotification.new(notification_type: :permission_updated,
                              recipient_user_id: recipient_user_id,
                              property_id: property_id)
    n.data = {message: 'Permission Updated'}
    n.save
    broadcast(n)
  end

  def work_order_completed(recipient_user_id, property_id)
    n = InAppNotification.new(notification_type: :work_order_completed,
                              recipient_user_id: recipient_user_id,
                              property_id: property_id)
    n.data = {message: 'Work Order Completed'}
    n.save
    broadcast(n)
  end

  def unread_message(chat_message, option = {})
    recipient_user_ids = (chat_message.chat.users - [ option[:current_user] ]).map(&:id)
    recipient_user_ids.each do |recipient_user_id|
      n = InAppNotification.new(notification_type: :unread_message,
                                recipient_user_id: recipient_user_id,
                                property_id: chat_message.property_id)
      n.data = {message: 'Unread Messages'}
      n.save
      broadcast(n)
    end
  end

  def new_feed(feed, option = {})
    recipient_user_ids = (feed.property.users - [ option[:current_user] ]).map(&:id)
    recipient_user_ids.each do |recipient_user_id|
      n = InAppNotification.new(notification_type: :new_feed,
                                recipient_user_id: recipient_user_id,
                                property_id: feed.property_id)
      n.data = {message: 'New Guest Logs'}
      n.save
      broadcast(n)
    end
  end

  def new_work_order(work_order, option = {})
    recipient_user_ids = [ work_order.opened_by_user_id ].compact.uniq
    recipient_user_ids.each do |recipient_user_id|
      n = InAppNotification.new(notification_type: :new_work_order,
                                recipient_user_id: recipient_user_id,
                                property_id: work_order.property_id)
      n.data = {message: 'New Work Order'}
      n.save
      broadcast(n)
    end
  end

  def assigned_work_order(work_order, option = {})
    return if work_order.assigned_to_id == -2
    recipient_user_ids = [ work_order.assigned_to_id ].compact.uniq
    recipient_user_ids.each do |recipient_user_id|
      n = InAppNotification.new(notification_type: :new_work_order,
                                recipient_user_id: recipient_user_id,
                                property_id: work_order.property_id)
      n.data = {message: 'New Work Order'}
      n.save
      broadcast(n)
    end
  end

  private

  def broadcast(in_app_notification)
    return unless in_app_notification.recipient_user.push_notification_setting&.enabled?
    h = in_app_notification.as_json(only: [ :notification_type, :recipient_user_id, :property_id, :read_at ])
    h.merge!(read: in_app_notification.read)
    ActionCable.server.broadcast "in_app_notification_#{in_app_notification.recipient_user_id}", h
  end
end
