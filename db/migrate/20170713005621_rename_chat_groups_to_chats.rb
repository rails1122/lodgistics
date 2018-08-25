class RenameChatGroupsToChats < ActiveRecord::Migration
  def change
    rename_table :chat_groups, :chats
    rename_column :chat_messages, :chat_group_id, :chat_id
  end
end
