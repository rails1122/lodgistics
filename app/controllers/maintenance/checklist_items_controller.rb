class Maintenance::ChecklistItemsController < Maintenance::BaseController
  before_action :set_maintenance_checklist_item,only: [:update,:destroy]
  skip_before_action :check_current_cycles_are_finished

  def index
    @checklist_items = Maintenance::ChecklistItem.for_property_id(Property.current_id).areas_with_subcategories
    render json: @checklist_items.to_json
  end

  def create
    p = checklist_item_params.merge!(property_id: Property.current_id)
    @checklist_item = Maintenance::ChecklistItem.new(p)
    @checklist_item.user_id = current_user.id
    @checklist_item.save
    render json: @checklist_item.to_json(only: [:id, :name, checklist_items: []]), status: 200
  end

  def update
    @checklist_item.update checklist_item_params
    render body: nil, status: 200
  end

  def destroy
    @checklist_item.update_attribute(:is_deleted, true)
    render body: nil, status: 200
  end

  private

  def set_maintenance_checklist_item
    @checklist_item = Maintenance::ChecklistItem.find params[:id]
  end

  def checklist_item_params
    params.require(:checklist_item).permit(
        :name,
        :area_id,
        :maintenance_type,
        :public_area_id,
        :area_row_order_position,
        :item_row_order_position,
        :public_area_row_order_position
    )
  end
end
