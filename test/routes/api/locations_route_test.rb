require 'test_helper'

class LocationsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/locations', controller: 'api/locations', action: 'index' }
end

