class AddUpdatedAtIndexToPurchaseOrder < ActiveRecord::Migration[5.0]
  def change
    add_index :purchase_orders, :updated_at
  end
end
