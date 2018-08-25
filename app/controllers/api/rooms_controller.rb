class Api::RoomsController < Api::BaseController
  include RoomsDoc

  skip_before_action :set_resource

  def checklist_items
    area_checklist_items = Maintenance::ChecklistItem.for_property_id(Property.current_id).by_type('rooms').areas
    result = area_checklist_items.map do |area_checklist_item|
      {
        id: area_checklist_item.id,
        name: area_checklist_item.name,
        checklist_items: area_checklist_item.checklist_items.map { |i| i.as_json(only: [:id, :name]) }
      }
    end
    render json: result
  end

  private

end
