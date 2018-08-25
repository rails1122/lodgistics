class AddNameIndexToVendor < ActiveRecord::Migration[5.0]
  def change
    add_index :vendors, :name
  end
end
