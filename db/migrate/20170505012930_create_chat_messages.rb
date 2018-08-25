class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
      t.integer :sender_id
      t.text :message
      t.integer :targetable_id
      t.string :targetable_type
      t.datetime :deleted_at
      t.integer :property_id

      t.timestamps
    end

    add_index :chat_messages, :sender_id
    add_index :chat_messages, [:targetable_id, :targetable_type]
    add_index :chat_messages, :property_id
  end
end
