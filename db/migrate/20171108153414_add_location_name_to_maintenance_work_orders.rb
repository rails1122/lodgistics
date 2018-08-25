class AddLocationNameToMaintenanceWorkOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :maintenance_work_orders, :location_name, :string
  end
end
