class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :eventable_type
      t.integer :eventable_id
      t.date :start_date
      t.date :end_date
      t.string :recurring_type
      t.integer :interval
      t.integer :days, array: true, default: []
      t.integer :property_id
      t.time :deleted_at, default: nil

      t.timestamps
    end
  end
end
