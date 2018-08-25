# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :chat do
    name { Faker::Lorem.sentence }
    user_id { create(:user).id }
    created_by_id { user.id }
    property { create(:property) }
  end
end
