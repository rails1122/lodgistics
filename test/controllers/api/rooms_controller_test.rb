require 'test_helper'

describe Api::RoomsController, "GET #checklist_items" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @property.setup_default_maintenance_categories(@user)
    @another_property = create(:property)
    @another_property.setup_default_maintenance_categories(@user)
  end

  it do
    get :checklist_items, format: :json
    json = JSON.parse(response.body)
    area_checklist_items = Maintenance::ChecklistItem.for_property_id(@property.id).areas
    assert(json.size == area_checklist_items.size)
    assert(json.map { |i| i['id'] }.sort == area_checklist_items.map(&:id).sort)
    area_checklist_items.each_with_index do |area_checklist_item, idx|
      h = {
        'id' => area_checklist_item.id,
        'name' => area_checklist_item.name,
        'checklist_items' => area_checklist_item.checklist_items.map { |i| i.as_json(only: [ :id, :name ]).stringify_keys }
      }
      assert(h == json[idx])
    end
  end
end


