class Api::ChecklistItemsController < Api::BaseController
  include ChecklistItemsDoc

  skip_before_action :set_resource

  load_and_authorize_resource :class => "Maintenance::ChecklistItem"

  before_action :set_public_area, only: [ :index ]

  def index
    if @public_area
      @checklist_items = @public_area.maintenance_checklist_items
    else
      @checklist_items = @checklist_items.for_property_id(Property.current_id)
    end
  end

  private

  def set_public_area
    @public_area = Maintenance::PublicArea.find(params[:public_area_id]) if (params[:public_area_id])
  end

end
