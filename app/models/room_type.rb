# == Schema Information
#
# Table name: room_types
#
#  id                :integer          not null, primary key
#  average_occupancy :integer
#  max_occupancy     :integer
#  min_occupancy     :integer
#  name              :string(255)
#  property_id       :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class RoomType < ApplicationRecord
  has_many :occupancies, class_name: "RoomOccupancy"
  belongs_to :property
end
