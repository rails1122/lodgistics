require 'test_helper'

class PushNotificationSettingsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/push_notification_settings', controller: 'api/push_notification_settings', action: 'index' }
  it { assert_routing({method: 'put', path: '/api/push_notification_settings'}, {controller: 'api/push_notification_settings', action: 'update'}) }
end
