class RenameChatGroupUsersToChatUsers < ActiveRecord::Migration
  def change
    rename_table :chat_group_users, :chat_users
  end
end
