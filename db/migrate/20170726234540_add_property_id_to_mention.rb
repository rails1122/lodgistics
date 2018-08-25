class AddPropertyIdToMention < ActiveRecord::Migration
  def change
    add_column :mentions, :property_id, :integer
    add_index :mentions, :property_id
  end
end
