class PushNotificationSetting < ApplicationRecord
  belongs_to :user

  def set_mention_snooze
    self.update(mentions_snoozed_at: DateTime.now)
  end

  def unset_mention_snooze
    self.update(mentions_snoozed_at: nil)
  end

  DEFAULT_SNOOZE_PERIOD_IN_HOUR = 4.0

  def snoozed?
    return false if mentions_snoozed_at.nil?
    (DateTime.now.to_time - mentions_snoozed_at.to_time) / 1.hours <= DEFAULT_SNOOZE_PERIOD_IN_HOUR
  end

end
