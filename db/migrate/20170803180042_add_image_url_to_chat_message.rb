class AddImageUrlToChatMessage < ActiveRecord::Migration
  def change
    add_column :chat_messages, :image_url, :text
  end
end
