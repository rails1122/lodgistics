require 'test_helper'

class ChatMessagesRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing({ method: 'post', path: '/chat_messages'}, {controller: 'chat_messages', action: 'create'}) }
end

