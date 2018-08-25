class Engage::Message < ApplicationRecord
  include SentientUser
  include AutoLinkable
  include RoomParsable

  auto_link_field :body
  room_content_field :body

  self.table_name = "engage_messages"

  acts_as_votable
  include PublicActivity::Common
  
  belongs_to :property
  belongs_to :work_order, class_name: 'Maintenance::WorkOrder', foreign_key: :work_order_id
  belongs_to :room, class_name: 'Maintenance::Room', foreign_key: :room_number, primary_key: :room_number
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id
  belongs_to :completed_by, class_name: 'User', foreign_key: :completed_by_id
  belongs_to :parent, class_name: 'Engage::Message', foreign_key: :parent_id, inverse_of: :replies
  has_many :replies, -> { order(updated_at: :desc) }, class_name: 'Engage::Message', foreign_key: :parent_id
  has_many :mentions, class_name: 'Mention', as: :mentionable, dependent: :destroy
  has_many :acknowledgements, class_name: 'Acknowledgement', as: :acknowledeable, dependent: :destroy

  validates :property, associated: true
  validates :body, :created_by_id, presence: true

  mount_uploader :image, ImageUploader

  attr_encrypted :body
  after_create :create_comment_activity

  # default_scope { where(property_id: Property.current_id) }

  scope :for_property_id, -> (given_property_id) { where(property_id: given_property_id) if given_property_id.present? }
  scope :threads, -> { where(parent_id: nil) }

  scope :created_between_dates, -> (start_date, end_date) {
    where("created_at >= ? AND created_at < ?", start_date.beginning_of_day, end_date.beginning_of_day + 1.day) if start_date.present? && end_date.present?
  }

  scope :updated_between_dates, -> (start_date, end_date) {
    where("updated_at >= ? AND updated_at < ?", start_date.beginning_of_day, end_date.beginning_of_day + 1.day) if start_date.present? && end_date.present?
  }

  scope :updated_between_datetimes, -> (start_datetime, end_datetime) {
    where("updated_at >= ? AND updated_at < ?", start_datetime, end_datetime) if start_datetime.present? && end_datetime.present?
  }

  scope :created_after, -> (d) { where('created_at > ?', d) if d.present? }
  scope :updated_after, -> (d) { where('updated_at > ?', d) if d.present? }

  scope :occurred_on, -> (date) {
    where(
      "(created_at >= ? AND created_at <= ?) OR (follow_up_start IS NOT NULL AND follow_up_end IS NOT NULL AND follow_up_start <= ? AND follow_up_end >= ?)",
      date.beginning_of_day, date.end_of_day, date, date
    ).order(id: :asc)
  }
  scope :follow_ups, -> (date) { where("follow_up_start <= ? AND follow_up_end >= ?", date, date) }
  scope :broadcast, -> (date = Time.current.to_date) {
    where("broadcast_start <= ? AND broadcast_end >= ?", date, date)
        .order(:id)
  }

  def self.broadcast_messages
    Engage::Message.for_property_id(Property.current_id).broadcast.includes(:created_by).map do |m|
      {
        id: m.id,
        body: m.body,
        created_at: I18n.l(m.created_at, format: :engage_time),
        created_at_date: I18n.l(m.created_at, format: :mini),
        created_by: m.created_by.name,
        created_by_avatar: m.created_by.avatar.thumb.url,
      }
    end
  end

  def image_url
    image.url
  end

  def mentioned_users
    User.where(id: self.mentioned_user_ids)
  end

  def user_ids_who_snoozed_mentions
    self.mentions.select { |i| i.snoozed? }.map(&:user_id)
  end

  def users_who_snoozed_mentions
    User.where(id: self.user_ids_who_snoozed_mentions)
  end

  def mentioned_user_ids
    self.mentions.map(&:user_id)
  end

  def mention_ids
    self.mentions.map(&:id)
  end

  def like=(value)
    if value == 'true'
      self.liked_by User.current
    end
  end

  def complete=(value)
    if value == 'true'
      self.complete!
    else
      self.uncomplete!
    end
  end

  def completed?
    completed_at.present?
  end

  def complete!
    self.completed_at = Time.current
    self.completed_by = User.current
    self.save!
  end

  def uncomplete!
    self.completed_at = nil
    self.completed_by = nil
    self.save!
  end

  def follow_up?
    follow_up_start.present? && follow_up_end.present?
  end

  def follow_up_show?(date)
    follow_up? && follow_up_start <= date && follow_up_end >= date
  end

  def broadcast?
    broadcast_start.present? && broadcast_end.present?
  end

  def broadcast_show?
    broadcast? && broadcast_start <= Time.current && broadcast_end >= Time.current
  end

  def show_up?(date)
    date.beginning_of_day <= created_at && created_at <= date.end_of_day
  end

  def follow_up_range
    if follow_up?
      follow_up_start == follow_up_end ? I18n.l(follow_up_start, format: :mini) : "#{I18n.l(follow_up_start, format: :mini)} - #{I18n.l(follow_up_end, format: :mini)}"
    end
  end

  def broadcast_range
    if broadcast?
      broadcast_start == broadcast_end ? I18n.l(broadcast_start, format: :mini) : "#{I18n.l(broadcast_start, format: :mini)} - #{I18n.l(broadcast_end, format: :mini)}"
    end
  end

  def create_comment_activity
    create_activity key: "comment.created", recipient: Property.current, owner: created_by
  end

  def body_without_mention_tags
    # TODO: temp fix for mobile app issue
    self.body.gsub(/<span class=\"atwho-inserted\">(.*?)<\/span>/, '\1')
  end

  def as_json(options = {})
    {
      id: id,
      title: title,
      body: body,
      room_number: "#{room_number}",
      wo_id: work_order.try(:id),
      created_at: I18n.l(created_at, format: :engage_time),
      created_at_date: I18n.l(created_at, format: :mini),
      created_by: created_by.name,
      created_by_avatar: created_by.avatar.thumb.url,
      completed_at: !!completed_at ? I18n.l(completed_at, format: :date_and_am_pm) : nil,
      completed_by: completed_by.try(:name),
      follow_up_show: follow_up_show?(options[:date]),
      follow_up_range: follow_up_range,
      follow_up_start: follow_up_start,
      follow_up_end: follow_up_end,
      broadcast_show: broadcast_show?,
      broadcast_range: broadcast_range,
      broadcast_start: broadcast_start,
      broadcast_end: broadcast_end,
      show_up: show_up?(options[:date]),
      liked: options[:user].liked?(self),
      likes_count: get_likes.count,
      likes: get_likes.map { |v| {name: v.voter.name, avatar: v.voter.avatar.thumb.url} },
      parent_id: parent_id,
      work_order_id: work_order_id,
      replies: replies.order(id: :desc).map { |r| {body: r.body, created_by: r.created_by.name, created_by_avatar: r.created_by.avatar.thumb.url, created_at: I18n.l(r.created_at, format: :engage_time), created_at_date: I18n.l(r.created_at, format: :mini)} },
      image_url: image_url
    }
  end

  # TODO : make sure mention_user_ids parameter type is of array
  def create_mention_records(mentioned_user_ids)
    return if mentioned_user_ids.blank?
    mentioned_user_ids.each do |user_id|
      m = Mention.new(user_id: user_id, mentionable: self, property_id: self.property_id)
      m.save
    end
  end

  def is_reply_feed
    self.parent.present?
  end
end
