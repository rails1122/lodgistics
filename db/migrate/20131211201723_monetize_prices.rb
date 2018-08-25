class MonetizePrices < ActiveRecord::Migration
  def change
    remove_column :vendor_items, :price
    add_monetize :vendor_items, :price
  end
end
