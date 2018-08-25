class ChangeImageColumnInChatsToText < ActiveRecord::Migration
  def up
    change_column :chats, :image, :text
  end

  def down
    change_column :chats, :image, :string
  end
end
