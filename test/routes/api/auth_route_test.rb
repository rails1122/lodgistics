require 'test_helper'

class AuthRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing({method: 'get', path: '/api/s3_sign'}, {controller: 'api/auth', action: 's3_sign'}) }
  it { assert_routing({method: 'post', path: '/api/auth'}, {controller: 'api/auth', action: 'create'}) }
  it { assert_routing({method: 'delete', path: '/api/auth'}, {controller: 'api/auth', action: 'destroy'}) }
end

