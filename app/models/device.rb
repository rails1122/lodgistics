class Device < ApplicationRecord
  belongs_to :user
  validates :token, presence: true, uniqueness: {scope: :user_id}
  validates :platform, presence: true, inclusion: {in: %w(ios android)}

  scope :android_only, -> { where(platform: 'android') }
  scope :ios_only, -> { where(platform: 'ios') }

end
