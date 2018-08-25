FactoryGirl.define do
  factory :room, class: Maintenance::Room do
    property_id { create(:property).id }
    floor { [1,2,3,4,5].sample }
    room_number { [101,202,303,404,505].sample }
    user_id { FactoryGirl.create(:user).id }
  end
end
