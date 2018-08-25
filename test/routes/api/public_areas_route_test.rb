require 'test_helper'

class PublicAreasRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/public_areas/checklist_items', controller: 'api/public_areas', action: 'checklist_items' }
  it { assert_routing '/api/public_areas/123/checklist_items', controller: 'api/checklist_items', action: 'index', public_area_id: '123' }
end

