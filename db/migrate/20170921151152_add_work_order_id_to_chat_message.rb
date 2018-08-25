class AddWorkOrderIdToChatMessage < ActiveRecord::Migration
  def change
    add_column :chat_messages, :work_order_id, :integer
  end
end
