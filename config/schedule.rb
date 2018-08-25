set :output, "/home/deploy/apps/lodgistics/shared/log/cron_log.log"

every 1.day do
  runner "Schedule.generate_next_occurrences"
end

# Scheduler to run unread direct/group message notifications task every 2 hours between 7 and 18 hours
every 1.day, at: '09:00 am' do
  rake "chat_message:generate_unread_notifications"
end

# Scheduler to run unread mentions notifications task every hour
every 1.day, at: '09:00 am' do
  rake "chat_message:generate_unread_mentions_notifications"
end

every :monday, at: '06:00 am' do
  runner 'WeeklyReport.run!'
end

#every :hour, at: 0 do
#  rake "chat_message:generate_unread_notifications"
#end
#
#every :hour, at: 30 do
#  rake "chat_message:generate_unread_notifications"
#end
#
#every :hour, at: 2 do
#  rake "chat_message:generate_unread_mentions_notifications"
#end
#
#every :hour, at: 32 do
#  rake "chat_message:generate_unread_mentions_notifications"
#end
