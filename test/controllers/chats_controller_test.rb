require 'test_helper'

describe ChatsController do
  include Devise::Test::ControllerHelpers

  let(:user){ create(:user, current_property_role: Role.agm) }
  let(:current_property) { user.current_property }
  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:chat_i_am_in) { create(:chat, user_ids: [ user.id, user1.id, user2.id ], property_id: current_property.id) }
  let(:another_chat_i_am_in) { create(:chat, user_ids: [ user.id, user1.id, user2.id ], property_id: current_property.id) }
  let(:chat_i_am_not_in) { create(:chat, user_ids: [ user1.id, user2.id ], property_id: current_property.id) }

  let(:my_chat_msg) { create(:chat_message, chat: chat_i_am_in, sender: user, property: current_property) }
  let(:my_chat_msg_2) { create(:chat_message, chat: another_chat_i_am_in, sender: user, property: current_property) }
  let(:other_chat_msg) { create(:chat_message, chat: chat_i_am_not_in, sender: user1, property: current_property) }
  let(:other_chat_msg_2) { create(:chat_message, chat: chat_i_am_not_in, sender: user2, property: current_property) }

  before do
    chat_i_am_in
    another_chat_i_am_in
    chat_i_am_not_in
    sign_in user
  end

  describe "GET #index" do
    it do
      get :index
      assert_response 200
      chats = assigns[:chats]
      assert_includes(chats, chat_i_am_in)
      assert_includes(chats, another_chat_i_am_in)
      refute_includes(chats, chat_i_am_not_in)
    end
  end

  describe "GET #new" do
    it do
      get :new
      assert_response 200
      users = assigns[:users]
      current_property_users = current_property.users
      assert(users == current_property_users)
    end
  end

  describe "GET #show" do
    before do
      my_chat_msg
      my_chat_msg_2
      other_chat_msg
      other_chat_msg_2
    end

    it 'should display chat messages in the chat' do
      get :show, params: { id: chat_i_am_in }
      assert_response 200
      chat_messages = assigns[:chat_messages]
      assert_includes(chat_messages, my_chat_msg)
      refute_includes(chat_messages, my_chat_msg_2)
    end

    it 'should return json containing chat messages in the chat' do
      get :show, params: { id: chat_i_am_in }, format: :json
      assert_response 200
      json = JSON.parse(response.body)
      ids = json.map { |e| e['id'] }
      assert_includes(ids, my_chat_msg.id)
      refute_includes(ids, my_chat_msg_2.id)
    end
  end

  describe "POST #create" do
    it do
      last_count = Chat.count
      post :create, format: :json, params: {
        chat: {
          name: 'Yes Members Group',
          user_ids: [ user1.id ],
          image_url: 'http://placekitten.com/320/200?image=1',
        }
      }
      assert_response 200
      Chat.count.must_equal last_count + 1
      last_chat = Chat.last
      assert_includes(last_chat.users, user1)
      assert_includes(last_chat.users, user)
    end
  end
end

