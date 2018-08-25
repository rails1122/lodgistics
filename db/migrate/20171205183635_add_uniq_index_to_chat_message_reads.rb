class AddUniqIndexToChatMessageReads < ActiveRecord::Migration[5.0]
  def change
    add_index :chat_message_reads, [ :user_id, :message_id], unique: true
  end
end
