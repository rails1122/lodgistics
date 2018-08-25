class CreateMobileVersions < ActiveRecord::Migration[5.0]
  def change
    create_table :mobile_versions do |t|
      t.integer :platform
      t.integer :version
      t.boolean :update_mandatory, default: false

      t.timestamps
    end
    add_index :mobile_versions, [ :platform, :version ], unique: true
  end
end
