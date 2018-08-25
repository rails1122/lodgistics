class RenameFeedImage < ActiveRecord::Migration[5.0]
  def change
    remove_column :engage_messages, :image_url
    add_column :engage_messages, :image, :string
  end
end
