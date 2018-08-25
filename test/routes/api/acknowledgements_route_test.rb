require 'test_helper'

class AcknowledgementsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/acknowledgements', controller: 'api/acknowledgements', action: 'index' }
  it { assert_routing '/api/acknowledgements/sent', controller: 'api/acknowledgements', action: 'sent' }
  it { assert_routing '/api/acknowledgements/received', controller: 'api/acknowledgements', action: 'received' }
  it { assert_routing '/api/acknowledgements/2', controller: 'api/acknowledgements', action: 'show', id: '2' }
  it { assert_routing({ method: 'post', path: '/api/acknowledgements'}, {controller: 'api/acknowledgements', action: 'create'}) }
end

