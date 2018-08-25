class AddRoomNumberToChatMessage < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_messages, :room_number, :string
  end
end
