# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :chat_message, :class => 'ChatMessage' do
    sender { create(:user) }
    message { Faker::Lorem.sentence }
    chat { create(:chat, user_ids: [ sender.id ]) }
    property { chat.property }
  end
end
