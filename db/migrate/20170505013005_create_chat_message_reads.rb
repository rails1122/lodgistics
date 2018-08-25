class CreateChatMessageReads < ActiveRecord::Migration
  def change
    create_table :chat_message_reads do |t|
      t.integer :user_id
      t.integer :message_id
      t.datetime :read_at

      t.timestamps
    end

    add_index :chat_message_reads, :user_id
    add_index :chat_message_reads, :message_id
  end
end
