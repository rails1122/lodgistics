require 'test_helper'

class WorkOrdersRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/work_orders', controller: 'api/work_orders', action: 'index' }
  it { assert_routing '/api/work_orders/123', controller: 'api/work_orders', action: 'show', id: '123' }
  it { assert_routing({ method: 'post', path: '/api/work_orders'}, {controller: 'api/work_orders', action: 'create'}) }
  it { assert_routing({ method: 'put', path: '/api/work_orders/123/close'}, {controller: 'api/work_orders', action: 'close', id: '123'}) }
  it { assert_routing({ method: 'put', path: '/api/work_orders/123'}, {controller: 'api/work_orders', action: 'update', id: '123'}) }
end

