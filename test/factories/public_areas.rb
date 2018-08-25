FactoryGirl.define do
  factory :public_area, class: Maintenance::PublicArea do
    property_id { create(:property).id }
    user_id { create(:user).id }
  end
end
