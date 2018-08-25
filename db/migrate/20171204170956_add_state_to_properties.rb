class AddStateToProperties < ActiveRecord::Migration[5.0]
  def change
    add_column :properties, :state, :string
  end
end
