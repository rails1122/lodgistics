class CreateAcknowledgements < ActiveRecord::Migration
  def change
    create_table :acknowledgements do |t|
      t.references :acknowledeable, polymorphic: true, index: { name: 'index_on_acknowledeable' }
      t.references :user, index: true, foreign_key: true
      t.datetime :checked_at
      t.integer :target_user_id

      t.timestamps null: false
    end
  end
end
