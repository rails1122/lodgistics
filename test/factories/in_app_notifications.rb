# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :in_app_notification do
    notifiable { create(:chat_message) }
    recipient_user_id { create(:user).id }
    property_id { notifiable.property_id }
  end
end
