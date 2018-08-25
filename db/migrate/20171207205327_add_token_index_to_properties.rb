class AddTokenIndexToProperties < ActiveRecord::Migration[5.0]
  def change
    add_index :properties, :token, unique: true
  end
end
