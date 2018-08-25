FactoryGirl.define do
  factory :engage_message, class: Engage::Message do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    created_by factory: [:user]
    property { create(:property) }
  end
end
