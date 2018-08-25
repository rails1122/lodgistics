class AddImageUrlToEngageMessage < ActiveRecord::Migration
  def change
    add_column :engage_messages, :image_url, :text
  end
end
