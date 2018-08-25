FactoryGirl.define do
  factory :task_item do
    task_list { create(:task_list) }
    property_id { Property.current_id }
    title { Faker::Lorem.sentence }
  end
end
