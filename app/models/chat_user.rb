class ChatUser < ApplicationRecord
  belongs_to :group, class_name: 'Chat', foreign_key: :group_id
  belongs_to :user

  validates :user_id, uniqueness: {scope: :group_id}
end
