ActionMailer::Base.delivery_method = :test
#ActionMailer::Base.delivery_method = :letter_opener

ActiveRecord::Base.transaction do
  # USERS CAN'T CUSTOMIZE THESE SO USE SEED DATA TO MANAGE THEM THESE RUN EVERY TIME
  unit_names = %W(Gallon LB Case Each Box OZ QT ML Pack Bar Cake Dozen LT LT LT Meters Inches GM KG Keg)
  Unit.find_or_initialize_many(unit_names.map{|name| {name: name}}, :name)

  roles = []
  Role.find_or_initialize_many(Role::ROLE_NAMES.map{|name| {name: name}}, :name)

  Report.find_or_initialize_many(Report::ALL_KINDS, :permalink)

  #USERS CAN CUSTOMIZE THESE SO THESE ONLY IF NO DATA IS ALREADY THERE
  hotel1 = Property.first

  unless Property.any?
    properties = [
      {
                :name => "Hotel 1",
        :contact_name => "Shaunak Patel",
      :street_address => "5625 Dillard Drive, Suite 215 B",
            :zip_code => "27518",
                :city => "Cary, NC",
               :phone => "919-854-1234",
               :token => "123456"
      }
    ]
    Property.find_or_initialize_many(properties, :name)
    hotel1 = Property.find_by(name: 'Hotel 1')
  end

  hotel1.switch!

  # Permission Attributes
  permission_attributes = YAML.load_file Rails.root.join('db', 'permission_attributes.yml')
  permission_attributes.each do |level1|
    pa1 = PermissionAttribute.find_or_initialize_by(level1.slice(:name, :subject, :action))
    pa1.options = level1[:options]
    pa1.save!
    level1[:items] ||= []
    level1[:items].each do |level2|
      pa2 = PermissionAttribute.find_or_initialize_by(level2.slice(:name, :subject, :action))
      pa2.parent = pa1
      pa2.options = level2[:options]
      pa2.save!

      level2[:items] ||= []
      level2[:items].each do |level3|
        pa3 = PermissionAttribute.find_or_initialize_by(level3.slice(:name, :subject, :action))
        pa3.parent = pa2
        pa3.options = level3[:options]
        pa3.save!
      end
    end
  end

  hotel1.setup_default_departments
  hotel1.setup_default_permissions

  user1 = User.new(name: 'GM', email: 'gm1@example.com', password: 'password')
  user1.current_property_role = Role.gm
  user1.title = 'GM'
  user1.confirmed_at = Time.current
  user1.departments << Department.where(name: 'All')
  user1.save!

  user2 = User.new(name: 'AGM', email: 'agm1@example.com', password: 'password')
  user2.current_property_role = Role.agm
  user2.title = 'AGM'
  user2.confirmed_at = Time.current
  user2.departments << Department.where(name: 'All')
  user2.save!

  user3 = User.new(name: 'Manager', email: 'maanger@example.com', password: 'password')
  user3.current_property_role = Role.manager
  user3.title = 'Manager'
  user3.confirmed_at = Time.current
  user3.departments << Department.where(name: 'All')
  user3.save!

  hotel1.setup_default_maintenance_public_areas user1
  hotel1.setup_default_maintenance_categories user1

  magic_tags = %W(Repair Replace Paint Touch-up Clean)
  Property.find_each do |p|
    Property.current_id = p.id
    magic_tags.each do |tag|
      t = MagicTag.find_or_initialize_by(name: tag)
      t.text = tag
      t.save!
    end
    Property.current_id = nil
  end

  50.times do |i|
    Maintenance::Room.create!(floor: i / 10, room_number: i, user_id: user1.id, property_id: hotel1.id)
  end

  20.times do |i|
    Maintenance::WorkOrder.create!(
      maintainable_type: 'Maintenance::Room',
      maintainable_id: Random.rand(50),
      opened_by_user_id: user1.id,
      description: Faker::Lorem.paragraph,
      property_id: hotel1.id,
      opened_at: Time.current
    )
  end

end #of the transaction
