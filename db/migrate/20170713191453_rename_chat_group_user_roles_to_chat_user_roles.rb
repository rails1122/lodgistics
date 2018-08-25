class RenameChatGroupUserRolesToChatUserRoles < ActiveRecord::Migration
  def change
    rename_table :chat_group_user_roles, :chat_user_roles
  end
end
