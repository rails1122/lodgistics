module NotificationHelper
  def self.send_push_notification(notified_user, alert, data = {})
    return if notified_user.blank?
    devices = notified_user.reload.devices.ios_only
    return if devices.blank?

    apns_app_name = Settings.apns_app_name
    apns_app = Rpush::Apns::App.find_by_name(apns_app_name)

    alert[:body] = strip_tags alert[:body]

    clear_invalid_token_notification

    devices.each do |device|
      # TODO : ugly...
      if (data[:type] && data[:type][:detail])
        notified_user_mention_id = Mention.where(id: data[:type][:detail][:mention_ids], user_id: notified_user.id).first.try(:id)
        if notified_user_mention_id
          data[:type][:detail][:notified_user_mention_id] = notified_user_mention_id
        end
      end
      device_token = device.token
      n = Rpush::Apns::Notification.new(app: apns_app, device_token: device_token, alert: alert, data: data)
      n.save
    end
  end

  def self.send_push_notification_gcm(notified_user, notification, additional_gcm_attributes = {})
    return if notified_user.blank?
    device_tokens = notified_user.devices.android_only.map(&:token)
    return if device_tokens.blank?

    gcm_app_name = Settings.gcm_app_name
    gcm_app = Rpush::Gcm::App.find_by_name(gcm_app_name)

    # clear invalid tokens?
    registration_ids = device_tokens

    # for testing :
    # data = { body: 'hello android', title: 'android notification title' }
    # data[:type] = { name: 'group_chat', property_token: '20345' }
    # data[:type][:detail] = { chat_id: 515, chat_message_id: 4757, chat_message_created_at: '2017-08-08T08:28:50.571-04:00' }
    data = notification
    data.merge!(additional_gcm_attributes)
    data[:body] = strip_tags data[:body]

    ## TODO : ugly...
    if (data[:type] && data[:type][:detail])
      notified_user_mention_id = Mention.where(id: data[:type][:detail][:mention_ids], user_id: notified_user.id).first.try(:id)
      if notified_user_mention_id
        data[:type][:detail][:notified_user_mention_id] = notified_user_mention_id
      end
    end

    n = Rpush::Gcm::Notification.new(app: gcm_app, registration_ids: registration_ids, data: data)
    n.save
  end

  def self.generate_alert_for_apn(obj = {})
    h = obj
    h.merge!("action-loc-key" => 'PLAY')
    h
  end

  # item = Engage::Message or ChatMessage
  def self.generate_non_aps_attributes(item, acknowledgement = false)
    {
      type: generate_type_attribute_for_apn(item, acknowledgement)
    }
  end

  # item = Engage::Message or ChatMessage
  def self.generate_additional_gcm_attributes(item)
    {
      type: generate_type_attribute_for_gcm(item)
    }
  end

  def self.clear_invalid_token_notification
    l = Rpush::Apns::Notification.where(delivered: false).where(error_code: 8)
    l.each { |i| i.destroy }
  end

  private

  def self.generate_type_attribute_for_apn(item, acknowledgement = false)
    type = {}
    if (item.is_a?(ChatMessage))
      type[:name] = item.chat.is_private ? 'direct_chat' : 'group_chat'
      type[:detail] = { chat_id: item.chat.id, chat_message_id: item.id,
                        chat_message_created_at: item.created_at }
      type[:detail][:mention_ids] = item.mention_ids if item.mention_ids.present?
    elsif (item.is_a?(Engage::Message))
      type[:name] = item.is_reply_feed ? 'feed_comment' : 'feed'
      if item.is_reply_feed
        type[:detail] = { feed_id: item.parent.id, feed_comment_id: item.id,
                          feed_created_at: item.parent.created_at,
                          feed_comment_created_at: item.created_at }
        type[:detail][:mention_ids] = item.mention_ids if item.mention_ids.present?
      else
        type[:detail] = { feed_id: item.id,
                          feed_created_at: item.created_at }
        type[:detail][:mention_ids] = item.mention_ids if item.mention_ids.present?
      end
    end
    type[:detail][:is_acknowledged] = true if acknowledgement
    type.merge!(property_token: item.property.try(:token))
    type
  end

  def self.generate_type_attribute_for_gcm(item)
    generate_type_attribute_for_apn(item)
  end

  def self.strip_tags(text)
    ActionController::Base.helpers.strip_tags(text)
  end

end
