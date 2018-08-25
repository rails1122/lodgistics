FactoryGirl.define do
  factory :rpush_apns_app, class: Rpush::Apns::App do
    name { 'lodgistics_test' }
    certificate { File.read('Distribution_Pem_Cert.pem') }
    environment { 'development' }
    connections { 1 }
    password { '' }
  end
end
