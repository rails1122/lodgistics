class ChatUserRole < ApplicationRecord
  belongs_to :property
  belongs_to :group, class_name: 'Chat', foreign_key: :group_id
  belongs_to :department
  belongs_to :role

  validates :property_id, :group_id, presence: true
end
