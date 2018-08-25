class AddImgHeightAndImgWidthToEngageMessage < ActiveRecord::Migration
  def change
    add_column :engage_messages, :image_height, :integer
    add_column :engage_messages, :image_width, :integer
  end
end
