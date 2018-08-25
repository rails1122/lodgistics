require 'test_helper'

class UsersRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/users/123', controller: 'api/users', action: 'show', id: '123' }
  it { assert_routing '/api/users', controller: 'api/users', action: 'index' }
  it { assert_routing({ method: 'put', path: '/api/users/123'}, {controller: 'api/users', action: 'update', id: '123'}) }
  it { assert_routing '/api/users/123/roles_and_departments', controller: 'api/users', action: 'roles_and_departments', id: '123' }
  it { assert_routing({ method: 'post', path: '/api/users'}, {controller: 'api/users', action: 'create'}) }
  it { assert_routing({ method: 'post', path: '/api/users/invite'}, {controller: 'api/users', action: 'invite'}) }
  it { assert_routing({ method: 'post', path: '/api/users/multi_invite'}, {controller: 'api/users', action: 'multi_invite'}) }
end

