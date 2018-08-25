class AddPropertyToken < ActiveRecord::Migration
  def change
    add_column :properties, :token, :string, limit: 6

    Property.reset_column_information

    Property.all.each do |p|
      settings_str = p.settings_before_type_cast || ''
      p.raw_write_attribute :settings, eval("{#{settings_str.split("\n")[1]}}")
      p.settings_will_change!
      p.generate_token
      p.save
    end
  end
end
