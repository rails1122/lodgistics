require 'test_helper'

class RolesRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/roles', controller: 'api/roles', action: 'index' }
end

