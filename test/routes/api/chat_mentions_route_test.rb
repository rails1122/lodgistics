require 'test_helper'

class ChatMentionsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing({ method: :put, path: '/api/chat_mentions/1' }, { controller: 'api/chat_mentions', action: 'update', id: '1' }) }
end

