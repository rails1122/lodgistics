# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mention do
    mentionable { create(:chat_message) }
    user { create(:user) }
    property_id { mentionable.property_id }
  end
end
