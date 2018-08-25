FactoryGirl.define do
  factory :task_list do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    property_id { Property.current_id }
  end
end