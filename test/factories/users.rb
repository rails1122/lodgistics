FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    confirmed_at { Time.now }
    department_ids { [FactoryGirl.create(:department).id] }
    current_property_role { Role.gm }
    username { "#{Faker::Internet.user_name}#{SecureRandom.hex}" }

    trait :unconfirmed do
      confirmed_at nil
    end

    trait :with_api_key do
      api_key { FactoryGirl.create(:api_key, user_id: id) }
    end

    factory :user_with_api_key, traits: [:with_api_key]

    after(:create) do |user|
      user.push_notification_setting.update(enabled: true)
    end
  end
end
