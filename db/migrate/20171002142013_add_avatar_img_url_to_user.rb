class AddAvatarImgUrlToUser < ActiveRecord::Migration
  def change
    add_column :users, :avatar_img_url, :text
  end
end
