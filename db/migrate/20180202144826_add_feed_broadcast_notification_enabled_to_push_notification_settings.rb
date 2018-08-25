class AddFeedBroadcastNotificationEnabledToPushNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :push_notification_settings, :feed_broadcast_notification_enabled, :boolean, default: true
  end
end
