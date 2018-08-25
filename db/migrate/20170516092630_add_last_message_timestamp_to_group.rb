class AddLastMessageTimestampToGroup < ActiveRecord::Migration
  def change
    add_column :chat_groups, :last_message_at, :datetime
  end
end
