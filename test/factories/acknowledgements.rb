# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :acknowledgement do
    acknowledeable { create(:chat_message) }
    user { create(:user) }
    target_user { create(:user) }
  end
end
