require 'test_helper'

class MentionsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/mentions', controller: 'api/mentions', action: 'index' }
  it { assert_routing({ method: :put, path: '/api/mentions/1' }, { controller: 'api/mentions', action: 'update', id: '1' }) }
  it { assert_routing({ method: :put, path: '/api/mentions/snooze' }, { controller: 'api/mentions', action: 'snooze' }) }
  it { assert_routing({ method: :put, path: '/api/mentions/unsnooze' }, { controller: 'api/mentions', action: 'unsnooze' }) }
  it { assert_routing({ method: :put, path: '/api/mentions/clear' }, { controller: 'api/mentions', action: 'clear' }) }
end

