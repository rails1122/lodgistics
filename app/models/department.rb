class Department < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  has_many :departments_users
  has_many :users, through: :departments_users
  has_many :permissions

  has_many :departments_tags
  has_many :categories, through: :departments_tags

  belongs_to :property
  scope :for_property_id, -> (given_property_id) { where(property_id: given_property_id) }

  default_scope { where(property_id: Property.current_id) }
  scope :with_roles, -> (roles) { joins(:users => :user_roles).where(user_roles: {role_id: roles}).distinct }
end
