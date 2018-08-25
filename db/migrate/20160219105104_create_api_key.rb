class CreateApiKey < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :access_token, null: false
      t.boolean :active, default: true
      t.integer :user_id

      t.timestamps
    end

    add_index :api_keys, :user_id
  end
end
