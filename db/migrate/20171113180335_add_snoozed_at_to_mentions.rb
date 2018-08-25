class AddSnoozedAtToMentions < ActiveRecord::Migration[5.0]
  def change
    add_column :mentions, :snoozed_at, :datetime
  end
end
