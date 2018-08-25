class ChangeMobileVersionColumnVersionToString < ActiveRecord::Migration[5.0]
  def change
    change_column :mobile_versions, :version, :string
  end
end
