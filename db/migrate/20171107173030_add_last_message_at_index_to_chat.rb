class AddLastMessageAtIndexToChat < ActiveRecord::Migration[5.0]
  def change
    add_index :chats, :last_message_at
  end
end
