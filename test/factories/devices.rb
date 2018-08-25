FactoryGirl.define do
  factory :device do
    token { SecureRandom.hex + SecureRandom.hex }
    enabled true
    platform 'ios'
    user
  end
end
