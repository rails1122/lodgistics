require 'test_helper'

chat_message_fields = [
    'id', 'message', 'sender_id', 'chat_id', 'mentioned_user_ids', 'reads_count', 'read', 'updated_at',
    'created_at', 'image_url', 'responding_to_chat_message_id', 'read_by_user_ids', 'sender_avatar_img_url',
    'mention_ids', 'work_order_id', 'work_order_url', 'work_order', 'room_number', 'room_id'
].sort

describe Api::ChatMessagesController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:chat_i_am_in) { create(:chat, user_ids: [ @user.id, user1.id, user2.id ], property_id: @property.id) }
  let(:another_chat_i_am_in) { create(:chat, user_ids: [ @user.id, user1.id, user2.id ], property_id: @property.id) }
  let(:chat_i_am_not_in) { create(:chat, user_ids: [ user1.id, user2.id ], property_id: @property.id) }

  let(:my_chat_msg) { create(:chat_message, chat: chat_i_am_in, sender: @user, property: @property) }
  let(:my_chat_msg_2) { create(:chat_message, chat: another_chat_i_am_in, sender: @user, property: @property) }
  let(:other_chat_msg) { create(:chat_message, chat: chat_i_am_not_in, sender: user1, property: @property) }
  let(:other_chat_msg_2) { create(:chat_message, chat: chat_i_am_not_in, sender: user2, property: @property) }

  it "should list chat messages in all chats I am in" do
    my_chat_msg
    my_chat_msg_2
    other_chat_msg
    other_chat_msg_2
    get :index, format: :json, params: { id: 'all' }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.keys.map(&:to_i).sort == [ chat_i_am_in.id, another_chat_i_am_in.id ].sort)

    chat_msg_ids_1 = json[chat_i_am_in.id.to_s].map { |i| i['id'] }
    assert_includes(chat_msg_ids_1, my_chat_msg.id)

    chat_msg_ids_2 = json[another_chat_i_am_in.id.to_s].map { |i| i['id'] }
    assert_includes(chat_msg_ids_2, my_chat_msg_2.id)
  end

  it "should filter out msgs after last_id" do
    my_chat_msg
    my_chat_msg_2
    other_chat_msg
    other_chat_msg_2
    get :index, format: :json, params: { id: 'all', last_id: my_chat_msg.id }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.keys.map(&:to_i).sort == [ another_chat_i_am_in.id ].sort)
    chat_msg_ids_2 = json[another_chat_i_am_in.id.to_s].map { |i| i['id'] }
    assert_includes(chat_msg_ids_2, my_chat_msg_2.id)
  end
end

describe Api::ChatMessagesController, "GET #updates" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:chat_i_am_in) { create(:chat, user_ids: [ @user.id, user1.id, user2.id ], property_id: @property.id) }

  it 'should list chat messages' do
    get :updates, format: :json
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.size == 0)
  end

  it 'should list chat messages' do
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id } }
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id } }
    chat_message_ids = ChatMessage.all.map(&:id)
    get :updates, format: :json, params: { chat_message_ids: chat_message_ids }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.size == 2)
    assert(json.first.keys.sort == chat_message_fields)
  end

  it 'should also accept comma separated chat_message_ids parameter' do
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id } }
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id } }
    chat_message_ids = ChatMessage.all.map(&:id).join(',')
    get :updates, format: :json, params: { chat_message_ids: chat_message_ids }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.size == 2)
    assert(json.first.keys.sort == chat_message_fields)
  end
end

describe Api::ChatMessagesController, "POST #create" do
  let(:rpush_apns_app) { create(:rpush_apns_app) }
  let(:rpush_gcm_app) { create(:rpush_gcm_app) }
  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:device_for_user1) { create(:device, user: user1) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:device_for_user2) { create(:device, user: user2) }

  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    rpush_apns_app
    rpush_gcm_app
    device_for_user1
    device_for_user2
  end

  let(:chat_i_am_in) { create(:chat, user_ids: [ @user.id, user1.id, user2.id ]) }
  let(:private_chat_i_am_in) { create(:chat, user_ids: [ @user.id, user1.id ], is_private: true) }
  let(:chat_i_am_not_in) { create(:chat, user_ids: [ user1.id, user2.id ]) }

  it do
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_not_in.id } }
    assert_response 422
    json = JSON.parse(response.body)
    assert(json.keys == ["error", "error_message"])
  end

  it "should update chat's last_message_at field" do
    chat_last_message_at = chat_i_am_in.last_message_at
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id } }
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id } }
    last_chat_msg = ChatMessage.last
    assert(chat_i_am_in.reload.last_message_at != chat_last_message_at)
    assert(chat_i_am_in.reload.last_message_at == last_chat_msg.created_at)
    assert(chat_i_am_in.last_message == last_chat_msg)
  end

  it 'should create a notifiction for original message sender' do
    assert(Rpush::Apns::Notification.count == 0)
    chat_message = create(:chat_message, chat: chat_i_am_in, property: @property, sender: user1)
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, responding_to_chat_message_id: chat_message.id } }
    assert(ChatMessage.last.responding_to_chat_message == chat_message)
    expected_count = 0
    assert(Rpush::Gcm::Notification.count == expected_count)
  end

  describe 'if chat message notification is disabled for message sender' do
    before do
      user1.push_notification_setting.update(chat_message_notification_enabled: false)
    end

    it 'should not create a push notifiction for original message sender' do
      chat_message = create(:chat_message, chat: chat_i_am_in, property: @property, sender: user1)
      post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, responding_to_chat_message_id: chat_message.id } }
      assert(ChatMessage.last.responding_to_chat_message == chat_message)
      expected_count = 0
      assert(Rpush::Gcm::Notification.count == expected_count)
    end
  end

  it do
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, image_url: 'http://placekitten.com/320/200?image=1' } }
    last_item = ChatMessage.last
    json = JSON.parse(response.body)
    json.keys.sort.must_equal chat_message_fields
    assert(json['id'] == last_item.id)
    assert(json['message'] == last_item.message)
    assert(json['chat_id'] == last_item.chat_id)
    assert(json['reads_count'] == last_item.reads_count)
    assert(json['read'] == last_item.read_by?(@user))
    assert(json['mentioned_user_ids'] == [])
    assert(json['image_url'] == last_item.image_url)
    assert(json['mention_ids'] == last_item.mention_ids)
    assert(json['responding_to_chat_message_id'] == last_item.responding_to_chat_message_id)
  end

  it 'should create a message' do
    assert(ChatMessage.count == 0)
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, image_url: 'http://placekitten.com/320/200?image=1' } }
    assert_response 200
    assert(ChatMessage.count == 1)
  end

  it 'should create a message and mentions and notification records' do
    assert(ChatMessage.count == 0)
    assert(Mention.count == 0)
    assert(Rpush::Apns::Notification.count == 0)
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, mentioned_user_ids: [ user1.id, user2.id ] } }
    assert_response 200
    assert(ChatMessage.count == 1)
    assert(Mention.count == 2)
    assert(Rpush::Apns::Notification.count == chat_i_am_in.users.size - 1)
  end

  it 'should not create a mention for a user who is not in the chat' do
    user_not_in_chat = create(:user, current_property_role: Role.gm)
    assert(Mention.count == 0)
    assert(Rpush::Apns::Notification.count == 0)
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, mentioned_user_ids: [ user_not_in_chat.id ] } }
    assert_response 200
    assert(ChatMessage.count == 1)
    assert(Mention.count == 0)
    expected_count = 0 + chat_i_am_in.users.size - 1
    assert(Rpush::Apns::Notification.count == expected_count)
  end

  describe 'if chat message notification is disabled for mentioned users' do
    before do
      user1.push_notification_setting.update(chat_message_notification_enabled: false)
      user2.push_notification_setting.update(chat_message_notification_enabled: false)
    end

    it 'should not create a push notifiction for mentioned users' do
      post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, mentioned_user_ids: [ user1.id, user2.id ] } }
      assert_response 200
      assert(ChatMessage.count == 1)
      assert(Mention.count == 2)
      assert(Rpush::Apns::Notification.count == 0)
    end
  end

  it 'should create in_app_notification for message receiving users excluding me' do
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, mentioned_user_ids: [ user1.id, user2.id ] } }
    recipient_user_ids = chat_i_am_in.users.map(&:id) - [ @user.id ]
    in_app_notis = InAppNotification.all
    assert(in_app_notis.map(&:recipient_user_id).sort == recipient_user_ids.sort)
    assert_response 200
  end

  it 'check in_app_notification data' do
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, mentioned_user_ids: [ user1.id, user2.id ] } }
    in_app_noti = InAppNotification.first
    last_msg = ChatMessage.last
    assert(in_app_noti.property_id == last_msg.property_id)
    assert(in_app_noti.notification_type == 'unread_message')
    assert(in_app_noti.data == { "message" => "Unread Messages" })
  end

  describe "if there are android devices associated" do
    let(:android_device_for_user1) { create(:device, user: user1, platform: 'android') }
    let(:android_device_for_user2) { create(:device, user: user2, platform: 'android') }

    before do
      android_device_for_user1
      android_device_for_user2
    end

    it 'should create a notifiction for original message sender' do
      assert(Rpush::Gcm::Notification.count == 0)
      chat_message = create(:chat_message, chat: chat_i_am_in, property: @property, sender: user1)
      post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, responding_to_chat_message_id: chat_message.id } }
      # num of orginal chat message author + num of users in chat - 1 (chat message sender)
      expected_count = 1 + chat_message.chat.users.size - 1
      assert(Rpush::Gcm::Notification.count == expected_count)
    end

    it 'should create a message and mentions and notification records' do
      assert(Rpush::Gcm::Notification.count == 0)
      post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id, mentioned_user_ids: [ user1.id, user2.id ] } }
      assert_response 200
      # num of mentioned users - current_user + num of users in chat - 1 (chat message sender)
      assert(Rpush::Gcm::Notification.count == chat_i_am_in.users.size - 1)
    end
  end

  it 'should parse urls and emails into links' do
    post :create, params: {
        chat_message: {
            message: 'http://google.com test@example.com',
            chat_id: chat_i_am_in.id
        }
    }
    last_msg = ChatMessage.last

    last_msg.message.must_include "<a href=\"http://google.com\">http://google.com</a>"
    last_msg.message.must_include "<a href=\"mailto:test@example.com\">test@example.com</a>"
  end

  describe 'parse room number' do
    [
        'parse room number: room #2342',
        'parse room number: room 2342',
        'parse room number: room2342',
        'parse room number: room #2342. ttt'
    ].each do |message|
      it "should parse room number for '#{message}'" do
        post :create, format: :json, params: {
            chat_message: {
                message: message,
                chat_id: chat_i_am_in.id
            }
        }
        assert_response 200

        api_response['room_number'].must_equal '2342'
        assert_nil api_response['room_id']
      end
    end

    it 'should link with room' do
      room = create(:room, room_number: 104, property_id: @property.id)
      post :create, format: :json, params: {
          chat_message: {
              message: 'parse room number: room #104',
              chat_id: chat_i_am_in.id
          }
      }
      assert_response 200

      api_response['room_number'].must_equal room.room_number
      api_response['room_id'].must_equal room.id
    end
  end
end

describe Api::ChatMessagesController, "PUT #mark_read_mass" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:chat_i_am_in) { create(:chat, user_ids: [ @user.id, user1.id, user2.id ], property: @property) }
  let(:chat_i_am_not_in) { create(:chat, user_ids: [ user1.id, user2.id ], property: @property) }
  let(:chat_msg) { create(:chat_message, chat: chat_i_am_in, sender: user1, property: @property) }
  let(:chat_msg_2) { create(:chat_message, chat: chat_i_am_in, sender: user2, property: @property) }
  let(:another_chat_msg) { create(:chat_message, chat: chat_i_am_not_in, sender: user1, property: @property) }

  it 'should update read flag' do
    put :mark_read_mass, format: :json, params: { chat_message_ids: [ chat_msg.id, chat_msg_2.id ] }
    assert_response 200
    assert(chat_msg.reload.read_by?(@user) == true)
    json = JSON.parse(response.body)
    assert(json.size == 2)
    json.each { |i| assert(i['read'] == true) }
    json.each { |i| assert(i['reads_count'] == 1) }
  end

  it "should update previous message's read status, too" do
    assert(chat_msg.id < chat_msg_2.id)
    put :mark_read_mass, format: :json, params: { chat_message_ids: [ chat_msg_2.id ] }
    assert(chat_msg_2.reload.read_by?(@user) == true)
    assert(chat_msg.reload.read_by?(@user) == true)
  end

  it "should not update future message's read status" do
    assert(chat_msg.id < chat_msg_2.id)
    put :mark_read_mass, format: :json, params: { chat_message_ids: [ chat_msg.id ] }
    assert(chat_msg.reload.read_by?(@user) == true)
    assert(chat_msg_2.reload.read_by?(@user) == false)
  end

  it 'should also accept comma separated chat_message_ids parameter' do
    chat_message_ids = [ chat_msg.id, chat_msg_2.id ].join(',')
    put :mark_read_mass, format: :json, params: { chat_message_ids: chat_message_ids }
    assert_response 200
    assert(chat_msg.reload.read_by?(@user) == true)
    json = JSON.parse(response.body)
    assert(json.size == 2)
    json.each { |i| assert(i['read'] == true) }
    json.each { |i| assert(i['reads_count'] == 1) }
  end

  it do
    put :mark_read_mass, format: :json, params: { chat_message_ids: [ chat_msg.id, chat_msg_2.id ] }
    put :mark_read_mass, format: :json, params: { chat_message_ids: [ chat_msg.id, chat_msg_2.id ] }
    json = JSON.parse(response.body)
    json.each { |i| assert(i['read'] == true) }
    json.each { |i| assert(i['reads_count'] == 1) }
  end

  it do
    put :mark_read_mass, format: :json, params: { chat_message_ids: [ chat_msg.id ] }
    json = JSON.parse(response.body)
    assert(json.first.keys.sort == chat_message_fields)
  end

  it 'should reject request to update chat msg from chat I am not in' do
    put :mark_read_mass, format: :json, params: { chat_message_ids: [ chat_msg.id, another_chat_msg.id ] }
    assert_response 401
  end
end


describe Api::ChatMessagesController, "PUT #mark_read" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:chat_i_am_in) { create(:chat, user_ids: [ @user.id, user1.id, user2.id ], property: @property) }
  let(:chat_i_am_not_in) { create(:chat, user_ids: [ user1.id, user2.id ], property: @property) }
  let(:chat_msg) { create(:chat_message, chat: chat_i_am_in, sender: user1, property: @property) }
  let(:another_chat_msg) { create(:chat_message, chat: chat_i_am_not_in, sender: user1, property: @property) }

  it 'should update read flag' do
    put :mark_read, format: :json, params: { id: chat_msg.id }
    assert_response 200
    assert(chat_msg.reload.read_by?(@user) == true)
  end

  it 'calling mark_read multiple times should only create 1 chat message read record' do
    last_count = ChatMessageRead.count
    put :mark_read, format: :json, params: { id: chat_msg.id }
    assert_response 200
    assert(ChatMessageRead.count == last_count + 1)
    put :mark_read, format: :json, params: { id: chat_msg.id }
    assert_response 200
    assert(ChatMessageRead.count == last_count + 1)
  end

  it do
    put :mark_read, format: :json, params: { id: chat_msg.id }
    json = JSON.parse(response.body)
    assert(json.keys.sort == chat_message_fields)
  end

  it do
    put :mark_read, format: :json, params: { id: chat_msg.id }
    json = JSON.parse(response.body)
    assert(json['read_by_user_ids'] == [ @user.id ])
    assert(chat_msg.reload.read_by_user_ids == [ @user.id ])
  end

  it 'should return 404' do
    put :mark_read, format: :json, params: { id: 9999 }
    assert_response 404
  end

  it 'should reject request to update chat msg from chat I am not in' do
    put :mark_read, format: :json, params: { id: another_chat_msg.id }
    assert_response 401
  end
end

describe Api::ChatMessagesController, "GET #show" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:chat_i_am_in) { create(:chat, user_ids: [ @user.id, user1.id, user2.id ], property: @property) }
  let(:chat_i_am_not_in) { create(:chat, user_ids: [ user1.id, user2.id ], property: @property) }
  let(:chat_msg) { create(:chat_message, chat: chat_i_am_in, sender: user1, property: @property) }
  let(:not_my_chat_msg) { create(:chat_message, chat: chat_i_am_not_in, sender: user1, property: @property) }

  it 'should return 404' do
    get :show, format: :json, params: { id: 9999 }
    assert_response 404
  end

  it do
    get :show, format: :json, params: { id: chat_msg.id }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.keys.sort == chat_message_fields)
  end

  it do
    get :show, format: :json, params: { id: not_my_chat_msg.id }
    assert_response 401
  end
end
