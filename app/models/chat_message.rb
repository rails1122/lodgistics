class ChatMessage < ApplicationRecord
  include AutoLinkable
  include RoomParsable

  auto_link_field :message
  room_content_field :message

  belongs_to :property
  has_many :reads, class_name: 'ChatMessageRead', foreign_key: :message_id
  has_many :mentions, class_name: 'Mention', as: :mentionable, dependent: :destroy
  has_many :acknowledgements, class_name: 'Acknowledgement', as: :acknowledeable, dependent: :destroy
  belongs_to :room, class_name: 'Maintenance::Room', foreign_key: :room_number, primary_key: :room_number
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :chat
  belongs_to :responding_to_chat_message, class_name: 'ChatMessage', foreign_key: :responding_to_chat_message_id
  belongs_to :work_order, class_name: 'Maintenance::WorkOrder', foreign_key: :work_order_id

  validates :property_id, :sender, :message, :chat_id, presence: true
  attr_encrypted :message

  validate :check_if_user_is_in_chat

  mount_uploader :image, ImageUploader

  scope :with_reads, -> (user_id) {
    joins("LEFT OUTER JOIN chat_message_reads ON chat_message_reads.message_id = chat_messages.id AND chat_message_reads.user_id = #{user_id}")
  }
  scope :unread, -> (user_id) {
    where.not(chat_messages: {sender_id: user_id}).with_reads(user_id).where(chat_message_reads: {user_id: nil})
  }
  scope :within, -> (from, to) {
    where(created_at: from.beginning_of_day..to.end_of_day)
  }

  scope :created_between, lambda {|start_date, end_date| where("created_at >= ? AND created_at <= ?", start_date, end_date )}

  after_create :touch_last_message

  def self.filter(options = {})
    from = options[:from].present? ? Date.parse(options[:from]) : Date.current
    to = options[:to].present? ? Date.parse(options[:to]) : Date.current

    messages = all.within(from, to)
    messages = messages.where("chat_messages.id > ?", options[:last_id]) if options[:last_id].present?
    messages = messages.where(chat_messages: {chat_id: options[:id]}) if options[:id] != 'all'
    messages = messages.order(id: :desc)
  end

  def read_by!(u)
    self.check_if_user_can_read(u)
    return if u.blank?
    ChatMessageRead.find_or_create_by!(user_id: u.id, message_id: self.id)
    previous_msgs = self.chat.chat_messages.where('id < ?', self.id)
    previous_msgs.each do |msg|
      ChatMessageRead.find_or_create_by!(user_id: u.id, message_id: msg.id)
    end
    self.reload
  end

  def image_url
    image.url
  end

  def can_be_read_by?(u)
    self.chat.users.include?(u)
  end

  def check_if_user_can_read(u)
    raise Errors::NotAuthorized unless self.can_be_read_by?(u)
  end

  def read_by?(u)
    reads.where(user_id: u.try(:id)).any?
  end

  def mentioned_users
    User.where(id: self.mentioned_user_ids)
  end

  def mentioned_user_ids
    self.mentions.map(&:user_id)
  end

  def mention_ids
    self.mentions.map(&:id)
  end

  def create_mention_records(mentioned_user_ids)
    mentioned_user_ids = mentioned_user_ids.map(&:to_i) & self.chat.users.map(&:id)
    mentioned_user_ids.each do |user_id|
      m = Mention.new(user_id: user_id, message_id: self.id, mentionable: self, property_id: self.property_id)
      m.save
    end
  end

  def read_by_user_ids
    reads.map(&:user_id)
  end

  def num_reads
    reads.size
  end

  def message_content
    begin
      self.message
    rescue
      'n/a'
    end
  end

  private

  def touch_last_message
    self.chat.last_message_at = self.created_at
    self.chat.save
  end

  def check_if_user_is_in_chat
    return if self.sender.is_lodgistics_bot?
    unless self.chat.users.include?(self.sender)
      errors.add(:chat, 'must contain sender_id')
    end
  end

end
