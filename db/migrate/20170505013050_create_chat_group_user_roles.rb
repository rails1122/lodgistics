class CreateChatGroupUserRoles < ActiveRecord::Migration
  def change
    create_table :chat_group_user_roles do |t|
      t.integer :group_id
      t.integer :department_id
      t.integer :role_id
      t.integer :property_id

      t.timestamps
    end

    add_index :chat_group_user_roles, :group_id
    add_index :chat_group_user_roles, :department_id
    add_index :chat_group_user_roles, :role_id
    add_index :chat_group_user_roles, :property_id
  end
end
