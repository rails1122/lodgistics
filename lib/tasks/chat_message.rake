namespace :chat_message do
  desc "Sends unread messages notifications to every user"
  task generate_unread_notifications: :environment do
    User.all.each do |user|
      UnreadMessageNotificationService.new.execute(user)
    end
  end

  desc "Sends unread mentions notifications to every user"
  task generate_unread_mentions_notifications: :environment do
    User.all.each do |user|
      UnreadMentionNotificationService.new.execute(user.id)
    end
  end
end
