module RoomParsable
  extend ActiveSupport::Concern

  included do
    before_save :parse_room_number
  end

  module ClassMethods
    attr_reader :field_name

    private

    def room_content_field(field_name)
      @field_name = field_name
    end
  end

  def parse_room_number
    field = self.class.field_name
    content = self.send field

    return true if content.blank?

    if send(:"#{field.to_s}_changed?")
      room_part = content.match(/(?:^|\s+)room\s*(?:#|\d)\S*/)
      if room_part
        room_number = room_part[0].sub('room', '').sub(/\s*/, '')
        room_number = room_number.chomp('.') if room_number[-1] == '.'
        room_number = room_number[1..-1] if room_number[0] == '#'

        self.room_number = room_number
      end
    end
  end
end
