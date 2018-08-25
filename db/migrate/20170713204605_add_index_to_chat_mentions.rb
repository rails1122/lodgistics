class AddIndexToChatMentions < ActiveRecord::Migration
  def change
    add_index :chat_mentions, [ :mentionable_type, :mentionable_id ]
  end
end
