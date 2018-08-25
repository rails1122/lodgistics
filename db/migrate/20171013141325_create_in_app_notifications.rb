class CreateInAppNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :in_app_notifications do |t|
      t.integer :recipient_user_id
      t.datetime :read_at
      t.references :notifiable, polymorphic: true
      t.integer :property_id
      t.integer :notification_type, default: 0
      t.string :action
      t.text :message

      t.timestamps
    end
  end
end
