require 'test_helper'

class PropertiesRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/properties', controller: 'api/properties', action: 'index' }
  it { assert_routing({ method: 'post', path: '/api/properties'}, {controller: 'api/properties', action: 'create'}) }
end

