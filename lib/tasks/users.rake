namespace :users do
  desc 'Disable main notification for all users'
  task disable_notifications: :environment do
    User.all.each do |user|
      unless user.push_notification_setting
        user.create_push_notification_setting(enabled: false)
      end
      user.push_notification_setting.update(enabled: false)
    end
  end

  desc 'Initialize intial profile images'
  task generate_avatars: :environment do
    User.all.each do |user|
      unless user.avatar.file&.exists?
        user.save_initials_img
      end
    end
  end
end