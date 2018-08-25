class CreateOccurrences < ActiveRecord::Migration
  def change
    enable_extension 'hstore'

    create_table :occurrences do |t|
      t.integer :eventable_id
      t.string :eventable_type
      t.integer :schedule_id
      t.date :date
      t.string :status
      t.hstore :option
      t.integer :index

      t.timestamps
    end

    add_index :occurrences, :schedule_id
  end
end
