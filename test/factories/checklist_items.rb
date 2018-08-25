FactoryGirl.define do
  factory :checklist_item, class: Maintenance::ChecklistItem do
    property_id { create(:property).id }
    user_id { create(:user).id }
    name { Faker::Lorem.sentence }
    maintenance_type { ["rooms", "public areas"].sample }
  end
end
