class AddFirstImgUrlAndSecondImgUrlToMaintenanceWorkOrder < ActiveRecord::Migration
  def change
    add_column :maintenance_work_orders, :first_img_url, :text
    add_column :maintenance_work_orders, :second_img_url, :text
  end
end
