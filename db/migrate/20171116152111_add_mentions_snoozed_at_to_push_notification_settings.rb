class AddMentionsSnoozedAtToPushNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :push_notification_settings, :mentions_snoozed_at, :datetime
  end
end
