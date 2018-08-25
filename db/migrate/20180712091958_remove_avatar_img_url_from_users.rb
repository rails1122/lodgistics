class RemoveAvatarImgUrlFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :avatar_img_url
  end
end
