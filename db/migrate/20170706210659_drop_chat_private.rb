class DropChatPrivate < ActiveRecord::Migration
  def up
    drop_table :chat_privates
  end

  def down
    create_table :chat_privates do |t|
      t.integer :property_id
      t.integer :sender_id
      t.integer :target_id
      t.datetime :last_message_at
      t.timestamps
    end

    add_index :chat_privates, :property_id
    add_index :chat_privates, [:sender_id, :target_id]
  end
end
