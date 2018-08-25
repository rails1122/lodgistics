class CreatePushNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :push_notification_settings do |t|
      t.references :user, foreign_key: true
      t.boolean :all_enabled, default: true

      t.timestamps
    end
  end
end
