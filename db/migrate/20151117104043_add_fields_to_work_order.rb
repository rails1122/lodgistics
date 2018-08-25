class AddFieldsToWorkOrder < ActiveRecord::Migration
  def change
    add_column :maintenance_work_orders, :recurring, :boolean, default: false
  end
end
