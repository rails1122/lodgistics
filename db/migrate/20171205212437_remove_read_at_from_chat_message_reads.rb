class RemoveReadAtFromChatMessageReads < ActiveRecord::Migration[5.0]
  def change
    remove_column :chat_message_reads, :read_at, :datetime
  end
end
