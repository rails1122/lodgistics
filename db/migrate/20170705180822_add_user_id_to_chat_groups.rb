class AddUserIdToChatGroups < ActiveRecord::Migration
  def change
    add_column :chat_groups, :user_id, :integer
    add_index :chat_groups, :user_id
  end
end
