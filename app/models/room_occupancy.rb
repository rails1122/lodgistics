# == Schema Information
#
# Table name: room_occupancies
#
#  id           :integer          not null, primary key
#  actual       :integer
#  forecast     :integer
#  room_type_id :integer
#  date         :date
#  created_at   :datetime
#  updated_at   :datetime
#

class RoomOccupancy < ApplicationRecord
  belongs_to :room_type
end
