require 'test_helper'

class PasswordsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing({method: 'post', path: '/api/passwords'}, {controller: 'api/passwords', action: 'create'}) }
  it { assert_routing({method: 'put', path: '/api/passwords'}, {controller: 'api/passwords', action: 'update'}) }
end

