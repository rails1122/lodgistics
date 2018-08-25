class AddDeletedAtToOccurrence < ActiveRecord::Migration
  def change
    add_column :occurrences, :deleted_at, :datetime
  end
end
