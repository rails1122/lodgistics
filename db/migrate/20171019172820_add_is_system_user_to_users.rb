class AddIsSystemUserToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_system_user, :boolean, default: false
  end
end
