class Api::PublicAreasController < Api::BaseController
  include PublicAreasDoc

  skip_before_action :set_resource

  load_and_authorize_resource :class => "Maintenance::PublicArea"

  def checklist_items
    result = @public_areas.map do |public_area|
      {
        id: public_area.id,
        name: public_area.name,
        property_id: public_area.property_id,
        checklist_items: public_area.maintenance_checklist_items.map { |i| i.as_json(only: [:id, :name ]) },
      }
    end
    render json: result
  end

end
