namespace :push_notification do
  desc "Initial setup for push notification"
  task setup: :environment do
    puts "Setting up push notification"
    env = ENV['RAKE_ENV']

    puts "\n"
    puts "1. Setup Apple Push Notification"
    apn_cert_filename = "pushcert-Prod-16-Aug.pem"
    apn_name = "lodgistics_#{env}"
    if Rpush::Apns::App.find_by_name(apn_name).present?
      puts "Apple Push Notification with name = #{apn_name} already exists!"
    else
      apn_app = Rpush::Apns::App.new
      apn_app.name = apn_name
      apn_app.environment = env
      apn_app.password = "1234"
      apn_app.connections = 1
      apn_app.certificate = File.read(apn_cert_filename)
      apn_app.save!
      puts "Created Rpush::Apns::App record and setup Apple Push Notification Service"
    end

    puts "\n"
    puts "2. Setup Google Push Notification"
    gcm_name = "lodgistics_gcm_#{env}"
    if Rpush::Gcm::App.find_by_name(gcm_name).present?
      puts "Google Push Notification with name = #{gcm_name} already exists!"
    else
      gcm_app = Rpush::Gcm::App.new
      gcm_app.name = gcm_name
      gcm_app.auth_key = "AIzaSyDkS1GLn9_JR2WnOde76PwWOw862B1f62k"
      gcm_app.connections = 1
      gcm_app.save!
      puts "Created Rpush::Gcm::App record and setup Google Push Notification Service"
    end

    User.all.each do |u|
      u.create_push_notification_setting if u.push_notification_setting.blank?
    end
  end

end
