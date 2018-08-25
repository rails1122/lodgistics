class Api::LocationsController < Api::BaseController
  include LocationsDoc

  skip_before_action :set_resource

  def index
    location_types = [ 'Room', 'Public Area', 'Equipment', 'Other' ]
    rooms = Maintenance::Room.unscoped.for_property_id(Property.current_id).order(:floor, :room_number).as_json
    public_areas = Maintenance::PublicArea.unscoped.for_property_id(Property.current_id).where(is_deleted: false).as_json
    equipments = Maintenance::Equipment.unscoped.for_property_id(Property.current_id).where(deleted_at: nil).as_json
    render json: { location_types: location_types, 'Room' => rooms, 'PublicArea' => public_areas, 'Equipment' => equipments }
  end

  private

end
