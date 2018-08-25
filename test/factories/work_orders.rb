FactoryGirl.define do
  factory :work_order, class: Maintenance::WorkOrder do
    assigned_to_id { -2 }
    opened_by_user_id { create(:user).id }
    property_id { create(:property).id }
    description { 'work order description' }
  end
end
