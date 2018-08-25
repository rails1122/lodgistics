class AddChatGroupIdToChatMessage < ActiveRecord::Migration
  def change
    add_column :chat_messages, :chat_group_id, :integer
  end
end
