require 'test_helper'

describe Api::LocationsController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it "return all types of location data" do
    get :index, format: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert(json.keys.sort == ['location_types', 'Room', 'PublicArea', 'Equipment' ].sort)
    assert(json['location_types'] == [ 'Room', 'Public Area', 'Equipment', 'Other' ])
    assert(json['Room'] == Maintenance::Room.unscoped.for_property_id(@property.id).order(:floor, :room_number).as_json)
    assert(json['PublicArea'] == Maintenance::PublicArea.unscoped.for_property_id(@property.id).as_json)
    assert(json['Equipment'] == Maintenance::Equipment.unscoped.for_property_id(@property.id).as_json)
  end
end


