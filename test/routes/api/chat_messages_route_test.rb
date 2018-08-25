require 'test_helper'

class ChatMessagesRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/api/chat_messages', controller: 'api/chat_messages', action: 'index' }
  it { assert_routing '/api/chat_messages/2', controller: 'api/chat_messages', action: 'show', id: '2' }
  it { assert_routing '/api/chat_messages/updates', controller: 'api/chat_messages', action: 'updates' }
  it { assert_routing({ method: 'post', path: '/api/chat_messages'}, {controller: 'api/chat_messages', action: 'create'}) }
  it { assert_routing({ method: :put, path: '/api/chat_messages/1/mark_read' }, { controller: 'api/chat_messages', action: 'mark_read', id: '1' }) }
  it { assert_routing({ method: :put, path: '/api/chat_messages/mark_read_mass' }, { controller: 'api/chat_messages', action: 'mark_read_mass' }) }
  it { assert_routing({ method: 'post', path: '/api/chat_messages/2/work_orders'}, {controller: 'api/work_orders', action: 'create', chat_message_id: '2'}) }
end

