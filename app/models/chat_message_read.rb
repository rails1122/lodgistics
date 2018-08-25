class ChatMessageRead < ApplicationRecord
  belongs_to :message, class_name: 'ChatMessage', foreign_key: :message_id, counter_cache: :reads_count
  belongs_to :user

  validates :user_id, uniqueness: {scope: :message_id}
end
