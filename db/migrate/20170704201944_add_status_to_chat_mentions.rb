class AddStatusToChatMentions < ActiveRecord::Migration
  def change
    add_column :chat_mentions, :status, :integer, default: 0
    add_index :chat_mentions, :status
  end
end
