require 'test_helper'

class ChatsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing({method: 'get', path: '/api/chats'}, {controller: 'api/chats', action: 'index'}) }
  it { assert_routing({method: 'post', path: '/api/chats'}, {controller: 'api/chats', action: 'create'}) }
  it { assert_routing({method: 'put', path: '/api/chats/1'}, {controller: 'api/chats', action: 'update', id: '1'}) }
  it { assert_routing({method: 'get', path: '/api/chats/group_only'}, {controller: 'api/chats', action: 'group_only'}) }
  it { assert_routing({method: 'get', path: '/api/chats/private_only'}, {controller: 'api/chats', action: 'private_only'}) }
  it { assert_routing({method: 'get', path: '/api/chats/1/messages'}, {controller: 'api/chats', action: 'messages', id: '1'}) }
end

