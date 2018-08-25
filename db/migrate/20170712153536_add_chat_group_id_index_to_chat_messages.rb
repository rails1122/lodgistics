class AddChatGroupIdIndexToChatMessages < ActiveRecord::Migration
  def change
    add_index :chat_messages, :chat_group_id
  end
end
