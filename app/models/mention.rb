class Mention < ApplicationRecord
  belongs_to :message, class_name: 'ChatMessage', foreign_key: :message_id
  belongs_to :user
  belongs_to :mentionable, polymorphic: true

  scope :for_property_id, -> (given_property_id) { where(property_id: given_property_id) }
  scope :by_ids, -> (ids) { where(id: ids) if ids.present? }
  scope :snoozed_only, -> { where("snoozed_at >= ?", 4.hours.ago) }
  scope :unsnoozed_only, -> { where("snoozed_at IS NULL OR snoozed_at < ?", 4.hours.ago) }

  enum status: {
    not_checked: 0,
    checked: 10
  }

  def mention_type
    return 'chat_mention' if self.mentionable_type == 'ChatMessage'
    return 'feed_mention' if self.mentionable_type == 'Engage::Message'
    'unknown'
  end

  def created_by
    self.mentionable_type == 'ChatMessage' ? self.mentionable.try(:sender) : self.mentionable.try(:created_by)
  end

  def target_group
    self.mentionable.try(:chat)
  end

  def mentioned_users
    self.mentionable.try(:mentioned_users) || []
  end

  def notification_msg
    mentioned_user_names_with_at_sign = self.mentioned_users.map { |i| "@#{i.name}" }.join(" ")
    msg = "#{self.created_by.try(:name)} mentioned you:\n#{mentioned_user_names_with_at_sign}"
    if self.mentionable_type == 'ChatMessage'
      msg += " #{self.mentionable.try(:message)}"
    elsif self.mentionable_type == 'Engage::Message'
      msg += " #{self.mentionable.try(:body)}"
    end
    msg
  end

  def acknowledged_by?(u)
    self.mentionable.acknowledgements.where(user_id: u.try(:id)).any?
  end

  def set_snooze(now = DateTime.now)
    self.update(snoozed_at: now)
  end

  def unset_snooze
    self.update(snoozed_at: nil)
  end

  DEFAULT_SNOOZE_PERIOD_IN_HOUR = 4.0

  def snoozed?
    return false if snoozed_at.nil?
    (DateTime.now.to_time - snoozed_at.to_time) / 1.hours <= DEFAULT_SNOOZE_PERIOD_IN_HOUR
  end
end
