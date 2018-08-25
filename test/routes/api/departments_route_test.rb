require 'test_helper'

class DepartmentsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/departments', controller: 'api/departments', action: 'index' }
end

