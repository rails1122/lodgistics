require 'test_helper'

class FeedsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/feeds', controller: 'api/feeds', action: 'index' }
  it { assert_routing '/api/feeds/2', controller: 'api/feeds', action: 'show', id: '2' }
  it { assert_routing({ method: 'post', path: '/api/feeds'}, {controller: 'api/feeds', action: 'create'}) }
  it { assert_routing({ method: 'post', path: '/api/feeds/2/work_orders'}, {controller: 'api/work_orders', action: 'create', feed_id: '2'}) }
  it { assert_routing '/api/feeds/broadcasts', controller: 'api/feeds', action: 'broadcasts' }
  it { assert_routing({ method: 'put', path: '/api/feeds/2'}, {controller: 'api/feeds', action: 'update', id: '2'}) }
end