class CreateChatGroups < ActiveRecord::Migration
  def change
    create_table :chat_groups do |t|
      t.string :name
      t.string :image
      t.integer :property_id
      t.integer :created_by_id
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :chat_groups, :property_id
    add_index :chat_groups, :created_by_id
  end
end
