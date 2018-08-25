require 'test_helper'

class RoomsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/rooms/checklist_items', controller: 'api/rooms', action: 'checklist_items' }
end

