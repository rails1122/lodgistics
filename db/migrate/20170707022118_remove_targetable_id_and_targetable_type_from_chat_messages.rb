class RemoveTargetableIdAndTargetableTypeFromChatMessages < ActiveRecord::Migration
  def up
    remove_column :chat_messages, :targetable_id, :integer
    remove_column :chat_messages, :targetable_type, :string
  end

  def down
    add_column :chat_messages, :targetable_id, :integer
    add_column :chat_messages, :targetable_type, :string

    add_index :chat_messages, [:targetable_id, :targetable_type]
  end
end
