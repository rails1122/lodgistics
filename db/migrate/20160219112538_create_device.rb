class CreateDevice < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :token, null: false
      t.string :platform, null: false
      t.boolean :enabled, default: true
      t.integer :user_id

      t.timestamps
    end

    add_index :devices, :user_id
  end
end
