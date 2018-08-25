class AddIndexInChatGroups < ActiveRecord::Migration
  def change
    add_index :chat_groups, :is_private
  end
end
