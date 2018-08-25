class ChangeDefaultValuesInWorkOrder < ActiveRecord::Migration
  def change
    change_column_default :maintenance_work_orders, :closing_comment, ''
    change_column_default :maintenance_work_orders, :first_img_url, ''
    change_column_default :maintenance_work_orders, :second_img_url, ''
  end
end
