require 'test_helper'

class ChecklistItemsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/checklist_items', controller: 'api/checklist_items', action: 'index' }
end

