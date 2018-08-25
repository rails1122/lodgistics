class AddUpdatedAtIndexToEngageMessage < ActiveRecord::Migration[5.0]
  def change
    add_index :engage_messages, :updated_at
  end
end
