class FeedNotificationService
  def initialize(params)
    @feed = params[:feed]
    @current_user = params[:current_user]
    @non_aps_attributes = NotificationHelper.generate_non_aps_attributes(@feed)
    @additional_gcm_attributes = NotificationHelper.generate_additional_gcm_attributes(@feed)
  end

  def send_notifications
    send_notification_to_parent_feed_user
    send_notification_to_mentioned_users
    send_notification_to_mentioned_users_in_parent
    send_notification_to_users_in_property
  end

  def notification_msg_for_mentioned_user
    name = feed.created_by.try(:name)
    "#{name} mentioned you:\n#{feed.body}"
  end

  def notification_msg_for_parent_feed
    name = feed.created_by.try(:name)
    "#{name} commented on your log post:\n#{feed.body}"
  end

  def notification_title_for_mentioned_user
    "You were mentioned"
  end

  def notification_title_for_parent_feed
    "New comment added to post in '#{@feed.property.name}'"
  end

  private

  attr_reader :feed, :current_user, :non_aps_attributes, :additional_gcm_attributes

  def send_notification_to_users_in_property
    target_users = @feed.property.users - [ @feed.created_by ] - @feed.mentioned_users
    return if target_users.blank?

    body = "#{@feed.created_by.try(:name)} posted :\n"
    body += @feed.body
    title = "New Log Post created in ‘#{@feed.property.name}’"
    alert = NotificationHelper.generate_alert_for_apn(body: body, title: title)
    target_users.each do |u|
      next unless u.push_notification_setting&.enabled?
      next unless u.push_notification_setting.all_new_log_posts

      NotificationHelper.send_push_notification(u, alert, non_aps_attributes)
      NotificationHelper.send_push_notification_gcm(u, { body: body, title: title }, additional_gcm_attributes)
    end
  end

  def send_notification_to_mentioned_users
    return if feed.mentioned_users.blank?
    body = notification_msg_for_mentioned_user
    title = notification_title_for_mentioned_user
    alert = NotificationHelper.generate_alert_for_apn(body: body, title: title)
    # NOTE : parent feed's creator will be notified with send_notification_to_parent_feed_user
    notified_users.each do |u|
      next unless u.push_notification_setting&.enabled?
      next unless u.push_notification_setting.feed_post_notification_enabled
      NotificationHelper.send_push_notification(u, alert, non_aps_attributes)
      NotificationHelper.send_push_notification_gcm(u, { body: body, title: title }, additional_gcm_attributes)
    end
  end

  def send_notification_to_parent_feed_user
    return if feed.parent.blank?
    notified_user = feed.parent.created_by
    return if notified_user == current_user
    return unless notified_user.push_notification_setting&.enabled?
    return unless notified_user.push_notification_setting.feed_post_notification_enabled

    body = notification_msg_for_parent_feed
    title = notification_title_for_parent_feed
    alert = NotificationHelper.generate_alert_for_apn(body: body, title: title)
    NotificationHelper.send_push_notification(notified_user, alert, non_aps_attributes)
    NotificationHelper.send_push_notification_gcm(notified_user, { body: body, title: title }, additional_gcm_attributes)
  end

  def send_notification_to_mentioned_users_in_parent
    return if feed.parent.blank?
    body = notification_msg_for_parent_feed
    title = notification_title_for_parent_feed
    alert = NotificationHelper.generate_alert_for_apn(body: body, title: title)
    mentioned_users_in_parent = feed.parent.mentioned_users - [ current_user ] - feed.parent.users_who_snoozed_mentions
    mentioned_users_in_parent.each do |notified_user|
      next unless notified_user.push_notification_setting&.enabled?
      next unless notified_user.push_notification_setting.feed_post_notification_enabled
      NotificationHelper.send_push_notification(notified_user, alert, non_aps_attributes)
      NotificationHelper.send_push_notification_gcm(notified_user, { body: body, title: title }, additional_gcm_attributes)
    end
  end

  private 

  def notified_users
    feed.mentioned_users - [ feed.parent.try(:created_by) ] - feed.user_ids_who_snoozed_mentions
  end
end
