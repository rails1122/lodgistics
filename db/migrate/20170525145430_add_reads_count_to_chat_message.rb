class AddReadsCountToChatMessage < ActiveRecord::Migration
  def change
    add_column :chat_messages, :reads_count, :integer, default: 0
  end
end
