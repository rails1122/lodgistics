class AddIsPrivateToChatGroups < ActiveRecord::Migration
  def change
    add_column :chat_groups, :is_private, :boolean, default: false
  end
end
