class CreateChatMentions < ActiveRecord::Migration
  def change
    create_table :chat_mentions do |t|
      t.integer :message_id
      t.integer :user_id

      t.timestamps
    end

    add_index :chat_mentions, :message_id
    add_index :chat_mentions, :user_id
  end
end
