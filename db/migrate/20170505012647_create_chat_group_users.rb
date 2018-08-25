class CreateChatGroupUsers < ActiveRecord::Migration
  def change
    create_table :chat_group_users do |t|
      t.integer :group_id
      t.integer :user_id
      t.integer :deleted_at

      t.timestamps
    end

    add_index :chat_group_users, :group_id
    add_index :chat_group_users, :user_id
  end
end
