require 'test_helper'

describe Api::PublicAreasController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it do
    public_area_1 = FactoryGirl.create(:public_area, property_id: @property.id)
    public_area_2 = FactoryGirl.create(:public_area, property_id: @property.id)
    checklist_item_in_public_area_1 = FactoryGirl.create(:checklist_item, property_id: @property.id, public_area_id: public_area_1.id)
    checklist_item_in_public_area_2 = FactoryGirl.create(:checklist_item, property_id: @property.id, public_area_id: public_area_2.id)
    get :checklist_items, format: :json
    json = JSON.parse(response.body)
    assert(json.size == 2)
    assert(json.map { |i| i['id'] }.sort == [ public_area_1.id, public_area_2.id ].sort)
    assert(json[0] == {
      'id' => public_area_1.id,
      'name' => public_area_1.name,
      'property_id' => public_area_1.property_id,
      'checklist_items' => [ checklist_item_in_public_area_1.as_json(only: [:id, :name]).stringify_keys ]
    })
  end
end


