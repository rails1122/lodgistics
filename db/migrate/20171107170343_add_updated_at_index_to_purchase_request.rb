class AddUpdatedAtIndexToPurchaseRequest < ActiveRecord::Migration[5.0]
  def change
    add_index :purchase_requests, :updated_at
  end
end
