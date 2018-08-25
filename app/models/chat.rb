class Chat < ApplicationRecord
  belongs_to :property
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id
  has_many :chat_users, foreign_key: :group_id, dependent: :destroy
  has_many :users, -> { active }, through: :chat_users
  has_many :user_roles, class_name: 'ChatUserRole', foreign_key: :group_id
  has_many :chat_messages

  belongs_to :user

  validates :property_id, :created_by_id, presence: true
  #validate :check_number_of_users

  validates :name, presence: true, if: :is_group?

  mount_uploader :image, ImageUploader

  # default scope is bad
  #default_scope { where(property_id: Property.current_id) }
  scope :for_property_id, -> (given_property_id) { where(property_id: given_property_id) }

  scope :private_chats_only, -> { where(is_private: true) }
  scope :group_chats_only, -> { where(is_private: false) }

  def target_user(current_user)
    (users - [ current_user ]).first
  end

  def last_message
    chat_messages.order(:id).last
  end

  def last_message_content
    begin
      last_message.try(:message)
    rescue
      'n/a'
    end
  end

  def chat_type
    self.is_private ? 'private_chat' : 'group_chat'
  end

  def is_group?
    self.is_private == false
  end

  def is_duplicate_private_chat?
    l = Chat.private_chats_only.where(property_id: self.property_id, user_id: self.user_id)
    l.each do |i|
      return true if i.user_ids.sort == self.user_ids.sort
    end
    false
  end

  def self.find_duplicate_private_chat(chat)
    l = Chat.private_chats_only.where(property_id: chat.property_id, user_id: chat.user_id)
    l.each do |i|
      return i if i.user_ids.sort == chat.user_ids.sort
    end
  end

  def is_already_created
    self.id != nil
  end

  def chat_title(current_user)
    return self.name unless self.is_private
    u = (self.users - [ current_user ]).first
    u.try(:name)
  end

  def notification_msg
    if (self.chat_type == 'group_chat')
      return "#{self.user.name} added you to the group '#{self.name}'"
    end
    "#{self.user.name} started a private conversation with you."
  end

  def image_url
    image.url
  end

  def save_default_image_url
    return if Rails.env.test?

    tmp_img = InitialsImageService.new.create_image(self.initials)
    temp_file = Tempfile.new(["chat_#{self.id}", 'png'])
    tmp_img.write(temp_file.path)

    self.image = temp_file
    self.save
  rescue => e
    Airbrake.notify(e)
    true
  end

  def initials
    return "" if self.name.blank?
    self.name.split(" ").map(&:first).map(&:capitalize).join("")
  end

  private

  def check_number_of_users
    return if self.user_ids.length >= 2
    errors.add(:user_ids, 'must have at least 2 users')
  end

end
