require 'test_helper'

describe Api::ChecklistItemsController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it do
    checklist_item_not_in_property = FactoryGirl.create(:checklist_item)
    checklist_item_in_property = FactoryGirl.create(:checklist_item, property_id: @property.id)
    get :index, format: :json
    json = JSON.parse(response.body)
    assert(json.size == 1)
    ids = json.map { |i| i['id'] }
    assert_includes(ids, checklist_item_in_property.id)
    refute_includes(ids, checklist_item_not_in_property.id)
  end

  it do
    public_area = FactoryGirl.create(:public_area, property_id: @property.id)
    checklist_item_in_public_area = FactoryGirl.create(:checklist_item, property_id: @property.id, public_area_id: public_area.id)
    checklist_item_not_in_public_area = FactoryGirl.create(:checklist_item, property_id: @property.id)
    get :index, format: :json, params: { public_area_id: public_area.id }
    json = JSON.parse(response.body)
    assert(json.size == 1)
    ids = json.map { |i| i['id'] }
    assert_includes(ids, checklist_item_in_public_area.id)
    refute_includes(ids, checklist_item_not_in_public_area.id)
  end
end


