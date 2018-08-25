FactoryGirl.define do
  factory :rpush_gcm_app, class: Rpush::Gcm::App do
    name { 'lodgistics_gcm_test' }
    auth_key { "AIzaSyDkS1GLn9_JR2WnOde76PwWOw862B1f62k" }
    environment { 'development' }
    connections { 1 }
  end
end
