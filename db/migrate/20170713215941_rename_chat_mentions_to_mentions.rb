class RenameChatMentionsToMentions < ActiveRecord::Migration
  def change
    rename_table :chat_mentions, :mentions
  end
end
