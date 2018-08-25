class RenameChatMessageMessage < ActiveRecord::Migration
  def change
    rename_column :chat_messages, :message, :encrypted_message
  end
end
