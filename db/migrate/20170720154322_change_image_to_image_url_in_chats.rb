class ChangeImageToImageUrlInChats < ActiveRecord::Migration
  def change
    rename_column :chats, :image, :image_url
  end
end
