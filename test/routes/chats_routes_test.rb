require 'test_helper'

class ChatsRouteTest < ActionDispatch::IntegrationTest
  it { assert_routing '/chats', controller: 'chats', action: 'index' }
  it { assert_routing '/chats/new', controller: 'chats', action: 'new' }
  it { assert_routing '/chats/2', controller: 'chats', action: 'show', id: '2' }
  it { assert_routing({ method: 'post', path: '/chats'}, {controller: 'chats', action: 'create'}) }
end

