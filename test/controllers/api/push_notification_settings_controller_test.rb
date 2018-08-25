require 'test_helper'

describe Api::PushNotificationSettingsController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it do
    get :index, format: :json
    assert_response 200
    json = JSON.parse(response.body)
    expected = ['id', 'user_id', 'feed_post_notification_enabled',
                'chat_message_notification_enabled', 'acknowledged_notification_enabled',
                'work_order_completed_notification_enabled', 'work_order_assigned_notification_enabled',
                'unread_mention_notification_enabled', 'unread_message_notification_enabled',
                'feed_broadcast_notification_enabled',
                'all_new_messages', 'all_new_log_posts']
    assert(json.keys.sort == expected.sort)
    assert(json['user_id'] == @user.id)
  end
end

describe Api::PushNotificationSettingsController, "PUT #update" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it do
    put :update, format: :json, params: { push_notification_setting: { feed_post_notification_enabled: false } }
    assert_response 200
    json = JSON.parse(response.body)
    expected = ['id', 'user_id', 'feed_post_notification_enabled',
                'chat_message_notification_enabled', 'acknowledged_notification_enabled',
                'work_order_completed_notification_enabled', 'work_order_assigned_notification_enabled',
                'unread_mention_notification_enabled', 'unread_message_notification_enabled',
                'feed_broadcast_notification_enabled',
                'all_new_messages', 'all_new_log_posts']
    assert(json.keys.sort == expected.sort)
    assert(json['user_id'] == @user.id)
    assert(json['feed_post_notification_enabled'] == false)
  end
end


