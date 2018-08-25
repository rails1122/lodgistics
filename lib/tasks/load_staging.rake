namespace :db do
  desc "Migrate staging db to dev server"
  task :load_staging => :environment do
    exceptions = ['nikhil', 'hugo']
    ActiveRecord::Base.transaction do
      User.all.each do |user|
        next if user.email.present? && (user.email.include?('inactive_') || exceptions.any? { |e| user.email.include?(e) })
        next if user.username.present? && (user.username.include?('inactive_') || exceptions.any? { |e| user.username.include?(e) })

        user.email = "inactive_#{user.email}" if user.email.present?
        user.username = "inactive_#{user.username}" if user.username.present?
        user.save(validate: false)
      end
    end
  end
end