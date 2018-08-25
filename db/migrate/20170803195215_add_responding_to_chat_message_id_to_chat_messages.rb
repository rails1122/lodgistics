class AddRespondingToChatMessageIdToChatMessages < ActiveRecord::Migration
  def change
    add_column :chat_messages, :responding_to_chat_message_id, :integer
  end
end
