require 'test_helper'

describe Api::InAppNotificationsController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it do
    my_notification = create(:in_app_notification, recipient_user: @user)
    another_notification = create(:in_app_notification)
    get :index, format: :json
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.count == 1)
    ids = json.map { |i| i['id'] }
    assert_includes(ids, my_notification.id)
    refute_includes(ids, another_notification.id)
    assert(json.first.keys.sort == ['id', 'read', 'read_at', 'property_id', 'notification_type', 'data'].sort)
  end
end


