require 'test_helper'

class InAppNotiticationsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/in_app_notifications', controller: 'api/in_app_notifications', action: 'index' }
end

