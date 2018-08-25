require 'test_helper'

class TaskListsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing({method: 'get', path: '/api/task_lists'}, {controller: 'api/task_lists', action: 'index'}) }
  it { assert_routing({method: 'get', path: '/api/task_lists/activities'}, {controller: 'api/task_lists', action: 'activities'}) }
  it { assert_routing({method: 'get', path: '/api/task_lists/1'}, {controller: 'api/task_lists', action: 'show', id: '1'}) }
end

