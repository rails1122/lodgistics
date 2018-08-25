class AddMentionableIdAndMentionableTypeToChatMentions < ActiveRecord::Migration
  def change
    add_column :chat_mentions, :mentionable_id, :integer
    add_column :chat_mentions, :mentionable_type, :string
  end
end
