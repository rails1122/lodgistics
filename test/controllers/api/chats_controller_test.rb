require 'test_helper'

describe Api::ChatsController, "POST #create" do
  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:rpush_apns_app) { create(:rpush_apns_app) }
  let(:rpush_gcm_app) { create(:rpush_gcm_app) }

  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    rpush_apns_app
    rpush_gcm_app
  end

  describe "when user has ios devices" do
    let(:user1_device) { create(:device, user: user1, platform: 'ios') }

    before do
      user1_device
    end

    it 'should create notification for user in the chat' do
      post :create, format: :json, params: {
        chat: {
          name: 'Yes Members Group',
          user_ids: [ user1.id ],
          image_url: 'http://placekitten.com/320/200?image=1',
        }
      }
      assert_response 201
      assert(Rpush::Apns::Notification.count == 1)
    end

    describe 'when user has chat message push notification disabled' do
      before do
        user1.push_notification_setting.update(chat_message_notification_enabled: false)
      end

      it 'should not create notification for the user' do
        post :create, format: :json, params: {
          chat: {
            name: 'Yes Members Group',
            user_ids: [ user1.id ],
            image_url: 'http://placekitten.com/320/200?image=1',
          }
        }
        assert_response 201
        assert(Rpush::Apns::Notification.count == 0)
      end
    end
  end

  describe "when user has android devices" do
    let(:user1_device) { create(:device, user: user1, platform: 'android') }

    before do
      user1_device
    end

    it 'should create notification for user in the chat' do
      post :create, format: :json, params: {
        chat: {
          name: 'Yes Members Group',
          user_ids: [ user1.id ],
          image_url: 'http://placekitten.com/320/200?image=1',
        }
      }
      assert_response 201
      assert(Rpush::Gcm::Notification.count == 1)
    end

    describe 'when user has chat message push notification disabled' do
      before do
        user1.push_notification_setting.update(chat_message_notification_enabled: false)
      end

      it 'should not create notification for the user' do
        post :create, format: :json, params: {
          chat: {
            name: 'Yes Members Group',
            user_ids: [ user1.id ],
            image_url: 'http://placekitten.com/320/200?image=1',
          }
        }
        assert_response 201
        assert(Rpush::Gcm::Notification.count == 0)
      end
    end

  end



  it 'should create chat and return json' do
    post :create, format: :json, params: {
      chat: {
        name: 'Yes Members Group',
        user_ids: [ user1.id ],
        image_url: 'http://placekitten.com/320/200?image=1',
      }
    }
    assert_response 201
    Chat.count.must_equal 1

    json = JSON.parse(response.body)
    json['id'].must_equal Chat.last.id
    json['name'].must_equal 'Yes Members Group'
    json['users'].length.must_equal 2
    assert(json['users'].map { |i| i['id'] }.sort == [user1.id, @user.id ].sort)
    json['owner_id'].must_equal @user.id
  end

  it 'should create chat with default auto generated image_url' do
    post :create, format: :json, params: {
      chat: {
        name: 'Yes Members Group',
        user_ids: [ user1.id ],
      }
    }
    assert_response 201
    Chat.count.must_equal 1
  end

  it 'last_message_at value should be nil' do
    post :create, format: :json, params: {
      chat: {
        name: 'Yes Members Group',
        user_ids: [ user1.id ]
      }
    }
    assert_response 201
    Chat.count.must_equal 1
    last = Chat.last
    assert(last.last_message_at == nil)
  end

  it 'is_private is false by default' do
    post :create, format: :json, params: {
      chat: {
        name: 'Yes Members Group',
        user_ids: [ user1.id ]
      }
    }
    assert_response 201
    Chat.count.must_equal 1
    Chat.last.is_private.must_equal false

    json = JSON.parse(response.body)
    json['is_private'].must_equal false
  end

  it 'is_private is set if given' do
    post :create, format: :json, params: {
      chat: {
        name: 'Private Chat Group',
        user_ids: [ user1.id ],
        is_private: true
      }
    }
    assert_response 201
    Chat.count.must_equal 1
    Chat.last.is_private.must_equal true

    json = JSON.parse(response.body)
    json['is_private'].must_equal true
  end

  it 'for is_private chat group, name can be omitted' do
    post :create, format: :json, params: {
      chat: {
        user_ids: [ user1.id ],
        is_private: true
      }
    }
    assert_response 201
    Chat.count.must_equal 1
  end

  it 'for is_private chat group, name field contains the name of user you chat with' do
    post :create, format: :json, params: {
      chat: {
        user_ids: [ user1.id ],
        is_private: true
      }
    }
    assert_response 201
    json = JSON.parse(response.body)
    assert(json['name'] == user1.name)
  end


  it 'for not private chat group, name must be provided' do
    post :create, format: :json, params: {
      chat: {
        user_ids: [ user1.id ],
        is_private: false,
      }
    }
    assert_response 422
    Chat.count.must_equal 0
  end

  describe 'when trying to create private chat group with same user twice' do
    before do
      post :create, format: :json, params: {
        chat: {
          name: 'Private Chat Group',
          user_ids: [ user1.id ],
          is_private: true
        }
      }
      @private_chat = Chat.last
      Chat.count.must_equal 1
    end

    it do
      post :create, format: :json, params: {
        chat: {
          name: 'Private Chat Group',
          user_ids: [ user1.id ],
          is_private: true
        }
      }
      Chat.count.must_equal 1
    end

    it do
      post :create, format: :json, params: {
        chat: {
          name: 'Private Chat Group',
          user_ids: [ user2.id ],
          is_private: true
        }
      }
      Chat.count.must_equal 2
    end
  end

  it 'required param not given returns status 400' do
    post :create, format: :json, params: { chat: { } }
    assert_response 400
  end

  it 'should include current as chat users' do
    post :create, format: :json, params: {
      chat: {
        name: 'Group',
        user_ids: [ user1.id ],
      }
    }
    json = JSON.parse(response.body)
    group_chat_user_ids = json['users'].map { |i| i['id'] }
    assert_includes(group_chat_user_ids, @user.id)
    assert_includes(group_chat_user_ids, user1.id)
  end

  it 'user can create more than 1 chat group for same property' do
    post :create, format: :json, params: {
      chat: {
        name: 'Group',
        user_ids: [ user1.id ],
      }
    }
    assert_response 201
    Chat.count.must_equal 1

    post :create, format: :json, params: {
      chat: {
        name: 'Group 2',
        user_ids: [ user1.id ],
      }
    }
    assert_response 201
    Chat.count.must_equal 2
  end

  describe "when user_ids are given" do
    it 'create with user ids' do
      post :create, format: :json, params: {
        chat: {
          name: 'Group with members',
          user_ids: [user1.id, user2.id]
        }
      }
      assert_response 201
      json = JSON.parse(response.body)
      json['users'].length.must_equal 3
      group_chat_user_ids = json['users'].map { |i| i['id'] }
      assert_includes(group_chat_user_ids, @user.id)
      assert_includes(group_chat_user_ids, user1.id)
      assert_includes(group_chat_user_ids, user2.id)
    end
  end

  describe 'when user_ids not given' do
    it 'create with user ids' do
      post :create, format: :json, params: {
        chat: {
          name: 'Group with members',
          user_ids: []
        }
      }
      assert_response 201
    end
  end
end

describe Api::ChatsController, "GET #index" do
  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }

  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  describe "when current user created groups, 1 private, 1 group" do
    before 'create 2 chat groups' do
      post :create, format: :json, params: {
        chat: { name: 'TEST GROUP', user_ids: [ user1.id ] }
      }
      post :create, format: :json, params: {
        chat: {
          name: 'PRIVATE TEST GROUP',
          is_private: true,
          user_ids: [ user1.id ]
        }
      }
    end

    it 'returns all chat group (both group and private) current user created' do
      get :index, format: :json
      json = JSON.parse(response.body)
      json.keys.must_equal ["groups", "privates"]

      groups = json['groups']
      privates = json['privates']

      group_chat_names = groups.map { |i| i['name'] }
      private_chat_names = privates.map { |i| i['name'] }
      assert_includes(group_chat_names, 'TEST GROUP')
      assert_includes(private_chat_names, user1.name)
    end
  end

  describe "when current user is in a chat group created by another user" do
    let(:group_chat_by_user1) { create(:chat, created_by: user1, property_id: @property.id, users: [ user1, @user ]) }
    let(:group_chat_by_user2) { create(:chat, created_by: user2, property_id: @property.id, users: [ user2, @user ]) }

    before do
      group_chat_by_user1
      group_chat_by_user2
    end

    it 'returns chat group created by other' do
      get :index, format: :json
      json = JSON.parse(response.body)
      groups = json['groups']
      privates = json['privates']
      assert(privates.length == 0)

      group_chat_ids = groups.map { |i| i['id'] }
      assert_includes(group_chat_ids, group_chat_by_user1.id)
      assert_includes(group_chat_ids, group_chat_by_user2.id)
    end
  end

  describe "when there is chat group for another property" do
    let(:group_chat_by_user1) { create(:chat, created_by: user1, property_id: @property.id, users: [ user1, @user ]) }
    let(:group_chat_in_another_property) { create(:chat, created_by: user2, users: [ user2, @user ]) }

    before do
      group_chat_by_user1
      group_chat_in_another_property
    end

    it 'returns chat group created by other' do
      get :index, format: :json
      json = JSON.parse(response.body)
      groups = json['groups']
      privates = json['privates']
      assert(privates.length == 0)
      assert(groups.length == 1)

      group_chat_ids = groups.map { |i| i['id'] }
      assert_includes(group_chat_ids, group_chat_by_user1.id)
      refute_includes(group_chat_ids, group_chat_in_another_property.id)
    end
  end
end

describe Api::ChatsController, "GET #group_only" do
  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:group_chat_by_user) { create(:chat, created_by: @user, property_id: @property.id, users: [ user1, @user ], updated_at: 1.day.ago) }
  let(:another_group_chat_by_user) { create(:chat, created_by: @user, property_id: @property.id, users: [ user1, @user ], updated_at: 1.hour.ago) }
  let(:private_chat_by_user) { create(:chat, created_by: @user, property_id: @property.id, users: [ user1, @user ], is_private: true) }
  let(:group_chat_in_other_property) { create(:chat, created_by: @user, users: [ user1, @user ]) }

  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    group_chat_by_user
    private_chat_by_user
    group_chat_in_other_property
  end

  it 'returns group chat only for current property' do
    another_group_chat_by_user
    get :group_only, format: :json
    json = JSON.parse(response.body)
    json.size.must_equal 2
    chat_ids = json.map { |i| i['chat']['id'] }
    assert_includes(chat_ids, group_chat_by_user.id)
    assert_includes(chat_ids, another_group_chat_by_user.id)
    refute_includes(chat_ids, private_chat_by_user.id)
    refute_includes(chat_ids, group_chat_in_other_property.id)
  end

  it 'should return chats ordered by last updated at' do
    another_group_chat_by_user
    get :group_only, format: :json
    json = JSON.parse(response.body)
    json.size.must_equal 2
    chat_ids = json.map { |i| i['chat']['id'] }
    assert(chat_ids == [another_group_chat_by_user.id, group_chat_by_user.id])
  end

  describe 'it should return last message' do
    let(:msg_list) { create_list(:chat_message, 5, chat: group_chat_by_user, sender: @user) }

    before do
      msg_list.map(&:touch)
    end

    it 'should return last message with details' do
      get :group_only, format: :json
      api_response.size.must_equal 1

      chat = api_response[0]['chat']
      chat['last_message']['id'].must_equal msg_list.last.id
      chat['last_message']['message'].must_equal msg_list.last.message
    end

    it 'should return image url as well' do
      image_msg = create(:chat_message, chat: group_chat_by_user, sender: @user)
      image_msg.touch

      get :group_only, format: :json
      api_response.size.must_equal 1

      chat = api_response[0]['chat']
      chat['last_message']['id'].must_equal image_msg.id
      chat['last_message']['message'].must_equal image_msg.message
    end
  end
end

describe Api::ChatsController, "GET #private_only" do
  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:group_chat_by_user) { create(:chat, created_by: @user, property_id: @property.id, users: [ user1, @user ]) }
  let(:private_chat_by_user) { create(:chat, created_by: @user, property_id: @property.id, users: [ user1, @user ], is_private: true) }
  let(:private_chat_in_other_property) { create(:chat, created_by: @user, users: [ user1, @user ], is_private: true) }

  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    group_chat_by_user
    private_chat_by_user
    private_chat_in_other_property
    user2
  end

  it 'should not include private chat in other property' do
    get :private_only, format: :json
    json = JSON.parse(response.body)
    chat_ids = json.map { |i| i['chat']['id'] }
    assert_includes(chat_ids, private_chat_by_user.id)
    refute_includes(chat_ids, private_chat_in_other_property.id)
  end

  it 'should not include group chat' do
    get :private_only, format: :json
    json = JSON.parse(response.body)
    chat_ids = json.map { |i| i['chat']['id'] }
    refute_includes(chat_ids, group_chat_by_user.id)
  end

  it 'return both created and not yet created chat room' do
    get :private_only, format: :json
    json = JSON.parse(response.body)
    json.size.must_equal (Property.current.users.size - 1)
    chat_ids = json.map { |i| i['chat']['id'] }
    assert_includes(chat_ids, private_chat_by_user.id)
    assert_includes(chat_ids, nil)

    chats = json.map { |i| i['chat'] }
    #puts chats.map { |c| c['is_already_created'] }
    assert chats.first['is_already_created']
    assert !chats.last['is_already_created']
  end

  it 'returned object also has target_user' do
    get :private_only, format: :json
    json = JSON.parse(response.body)
    json.size.must_equal (Property.current.users.size - 1)
    target_user_ids = json.map { |i| i['target_user']['id'] }
    assert_includes(target_user_ids, user1.id)
    assert_includes(target_user_ids, user2.id)
    refute_includes(target_user_ids, @user.id)
  end

  it 'returned object has created chat at top, and follows uninitialized chats sorted by User names' do
    get :private_only, format: :json
    json = JSON.parse(response.body)
    json.size.must_equal (Property.current.users.size - 1)
   
    sorted_names  = (Property.current.users - [ @user, user1 ]).pluck(:name).sort
    names_in_chat = json[1..json.size].map{ |i| i['target_user']['name'] }

    assert_equal user1.name, json.first['target_user']['name']
    assert_equal sorted_names.join(','), names_in_chat.join(',')
  end
end

describe Api::ChatsController, "GET #messages" do
  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }

  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token

    # 'create a chat group and messages'
    post :create, format: :json, params: {
      chat: { name: 'TEST GROUP', user_ids: [ user1.id ] }
    }
    @group_chat = Chat.last
    post :create, format: :json, params: {
      chat: { name: 'ANOTHER TEST GROUP', user_ids: [ user1.id ] }
    }
    @another_group_chat = Chat.last

    @msg1 = create(:chat_message, sender_id: user1.id, message: 'Msg 1', property: @property, chat_id: @group_chat.id, created_at: 3.days.ago)
    @msg2 = create(:chat_message, sender_id: user1.id, message: 'Msg 2', property: @property, chat_id: @group_chat.id)
    @msg_in_other_chat = create(:chat_message, sender_id: user1.id, message: 'Msg in Another Chat Group', property: @property, chat_id: @another_group_chat.id)
  end

  it 'returns all messages in that group chat' do
    get :messages, format: :json, params: { id: @group_chat.id }
    json = JSON.parse(response.body)
    json.length.must_equal 2
    message_ids = json.map { |i| i['id'] }
    assert_includes(message_ids, @msg1.id)
    assert_includes(message_ids, @msg2.id)
    refute_includes(message_ids, @msg_in_other_chat.id)
  end

  it do
    get :messages, format: :json, params: { id: @group_chat.id }
    json = JSON.parse(response.body)
    assert(json.first.keys.sort == ['id', 'message', 'sender_id', 'chat_id', 'mentioned_user_ids', 'reads_count', 'read', 'updated_at', 'created_at', 'image_url', 'responding_to_chat_message_id', 'read_by_user_ids', "mention_ids", "work_order_id", "work_order_url", "work_order", "room_id", "room_number", "sender_avatar_img_url"].sort)
  end

  it 'returns only mesages created after start_date' do
    start_date = 1.day.ago.strftime("%Y-%m-%d")
    get :messages, format: :json, params: { id: @group_chat.id, start_date: start_date }
    json = JSON.parse(response.body)
    json.length.must_equal 1
    message_ids = json.map { |i| i['id'] }
    refute_includes(message_ids, @msg1.id)
    assert_includes(message_ids, @msg2.id)
    refute_includes(message_ids, @msg_in_other_chat.id)
  end

  it 'returns only mesages created after start_date' do
    start_date = 4.day.ago.strftime("%Y-%m-%d")
    end_date = (DateTime.now + 1.day).strftime("%Y-%m-%d")
    get :messages, format: :json, params: { id: @group_chat.id, start_date: start_date, end_date: end_date }
    json = JSON.parse(response.body)
    json.length.must_equal 2
    message_ids = json.map { |i| i['id'] }
    assert_includes(message_ids, @msg1.id)
    assert_includes(message_ids, @msg2.id)
    refute_includes(message_ids, @msg_in_other_chat.id)
  end

  it 'returns only mesages > the given message_id' do
    get :messages, format: :json, params: { id: @group_chat.id, message_id: @msg1.id }
    json = JSON.parse(response.body)
    json.length.must_equal 1
    message_ids = json.map { |i| i['id'] }
    refute_includes(message_ids, @msg1.id)
    assert_includes(message_ids, @msg2.id)
    refute_includes(message_ids, @msg_in_other_chat.id)
  end
end

describe Api::ChatsController, "PUT #update" do
  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }

  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  describe "for group chat" do
    before 'create a group with user1' do
      post :create, format: :json, params: {
        chat: {
          name: 'TEST GROUP',
          user_ids: [ user1.id ]
        }
      }
      @group = Chat.last
      @group.users.count.must_equal 2
    end

    it 'should update name and users' do
      updated_user_ids = @group.users.map(&:id) << user2.id
      put :update, format: :json, params: {
        id: @group.id,
        chat: {
          name: 'Updated Group Name',
          user_ids: updated_user_ids,
        }
      }
      assert_response 200
      @group.reload
      @group.users.count.must_equal 3
      assert_equal(@group.users.map(&:id).sort, updated_user_ids.sort)
      @group.name.must_equal 'Updated Group Name'
      json = JSON.parse(response.body)
      assert(json['users'].size == 3)
    end

    it 'cannot change is_private property' do
      @group.is_private.must_equal false
      put :update, format: :json, params: {
        id: @group.id,
        chat: { is_private: true }
      }
      assert_response 200
      @group.reload
      @group.is_private.must_equal false
    end
  end

  describe "for private chat" do
    before 'create a group with user1' do
      post :create, format: :json, params: {
        chat: {
          name: 'private GROUP',
          is_private: true,
          user_ids: [ user1.id ]
        }
      }
      @group = Chat.last
      @group.users.count.must_equal 2
    end

    it 'cannot change user_ids' do
      user_ids = @group.users.map(&:id)
      assert_includes(user_ids, @user.id)
      assert_includes(user_ids, user1.id)
      put :update, format: :json, params: {
        id: @group.id,
        chat: { user_ids: [ user1.id, user2.id ] }
      }
      assert_response 200
      updated_user_ids = @group.reload.users.map(&:id)
      assert_includes(updated_user_ids, @user.id)
      assert_includes(updated_user_ids, user1.id)
      refute_includes(updated_user_ids, user2.id)
    end
  end
end
