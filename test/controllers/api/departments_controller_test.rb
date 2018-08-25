require 'test_helper'

describe Api::DepartmentsController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it 'should only list departments for current property' do
    another_property = create(:property)
    dept_in_another_property = create(:department, property_id: another_property.id)
    dept_in_current_property = create(:department, property_id: @property.id)

    get :index, format: :json
    json = JSON.parse(response.body)
    ids = json.map { |i| i['id'] }
    assert_includes(ids, dept_in_current_property.id)
    refute_includes(ids, dept_in_another_property.id)
  end
end


