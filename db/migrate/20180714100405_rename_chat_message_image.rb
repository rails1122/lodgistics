class RenameChatMessageImage < ActiveRecord::Migration[5.0]
  def change
    remove_column :chat_messages, :image_url
    add_column :chat_messages, :image, :string
  end
end
