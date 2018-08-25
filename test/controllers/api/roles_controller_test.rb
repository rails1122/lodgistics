require 'test_helper'

describe Api::RolesController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it do
    get :index, format: :json
    json = JSON.parse(response.body)
    assert(json.count == Role.count)
  end
end


