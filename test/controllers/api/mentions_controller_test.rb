require 'test_helper'

describe Api::MentionsController, "PUT #update" do
  let(:chat_user1) { create(:user, current_property_role: Role.gm) }
  let(:chat_user2) { create(:user, current_property_role: Role.gm) }
  let(:chat) { create(:chat, created_by: @user, property_id: @property.id, users: [ chat_user1, @user, chat_user2 ]) }
  let(:chat_msg) do
    create(:chat_message, chat_id: chat.id, sender: chat_user1, property: @property)
  end

  let(:my_mention) { create(:mention, user_id: @api_key.user_id, mentionable_type: 'ChatMessage', mentionable_id: chat_msg.id) }
  let(:other_mention) { create(:mention, user_id: chat_user2.id, mentionable_type: 'ChatMessage', mentionable_id: chat_msg.id) }

  before 'set headers' do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    other_mention
    my_mention
  end

  it 'cannot update chat mention at other person' do
    put :update, format: :json, params: {
      id: other_mention.id,
      mention: { status: 'checked' }
    }
    assert_response :unauthorized
  end

  it 'cannot update with invalid status' do
    put :update, format: :json, params: {
      id: my_mention.id,
      mention: { status: 'invalid_status' }
    }
    assert_response 422
    json = JSON.parse(response.body)
    json['error'].must_equal "'invalid_status' is not a valid status"
  end

  it 'can update my chat mention' do
    put :update, format: :json, params: {
      id: my_mention.id,
      mention: { status: 'checked' }
    }
    assert_response 200

    json = JSON.parse(response.body)
    json['id'].must_equal my_mention.id
    json['status'].must_equal 'checked'

    my_mention.reload.status.must_equal 'checked'
  end
end

describe Api::MentionsController, "PUT #clear" do
  let(:chat_user1) { create(:user, current_property_role: Role.gm) }
  let(:chat_user2) { create(:user, current_property_role: Role.gm) }
  let(:chat) { create(:chat, created_by: @user, property_id: @property.id, users: [ chat_user1, @user, chat_user2 ]) }
  let(:chat_msg) do
    create(:chat_message, chat_id: chat.id, sender: chat_user1, property: @property)
  end

  let(:my_mention) { create(:mention, user_id: @api_key.user_id, mentionable_type: 'ChatMessage', mentionable_id: chat_msg.id) }
  let(:my_checked_mention) { create(:mention, status: 'checked', user_id: @api_key.user_id, mentionable_type: 'ChatMessage', mentionable_id: chat_msg.id) }
  let(:other_mention) { create(:mention, user_id: chat_user2.id, mentionable_type: 'ChatMessage', mentionable_id: chat_msg.id) }

  before 'set headers' do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    other_mention
    my_mention
    my_checked_mention
    assert(my_mention.status == 'not_checked')
    assert(my_checked_mention.status == 'checked')
    assert(other_mention.status == 'not_checked')
  end

  it do
    put :clear, format: :json
    assert_response 200
    assert(my_mention.reload.status == 'checked')
    assert(my_checked_mention.status == 'checked')
    assert(other_mention.reload.status == 'not_checked')
    json = JSON.parse(response.body)
    assert(json.size == 1)
    ids = json.map { |i| i['id'] }
    assert(ids == [my_mention.id])
    json.each do |i|
      assert(i['status'] == 'checked')
    end
  end
end

describe Api::MentionsController, "PUT #snooze #unsnooze" do
  let(:chat_user1) { create(:user, current_property_role: Role.gm) }
  let(:chat_user2) { create(:user, current_property_role: Role.gm) }
  let(:chat) { create(:chat, created_by: @user, property_id: @property.id, users: [ chat_user1, @user, chat_user2 ]) }
  let(:chat_msg) do
    create(:chat_message, chat_id: chat.id, sender: chat_user1, property: @property)
  end

  let(:my_mention) { create(:mention, user_id: @api_key.user_id, mentionable_type: 'ChatMessage', mentionable_id: chat_msg.id) }
  let(:my_mention_2) { create(:mention, user_id: @api_key.user_id, mentionable_type: 'ChatMessage', mentionable_id: chat_msg.id) }
  let(:other_mention) { create(:mention, user_id: chat_user2.id, mentionable_type: 'ChatMessage', mentionable_id: chat_msg.id) }

  before 'set headers' do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    other_mention
    my_mention
    my_mention_2
    assert(my_mention.snoozed? == false)
    assert(my_mention_2.snoozed? == false)
    assert(other_mention.snoozed? == false)
  end

  it 'should snooze all mentions' do
    put :snooze, format: :json
    assert_response 200
    assert(my_mention.reload.snoozed? == true)
    assert(other_mention.reload.snoozed? == false)
    json = JSON.parse(response.body)
    assert(json.size == 2)
    ids = json.map { |i| i['mention_id'] }
    assert(ids == [ my_mention.id, my_mention_2.id ])
    json.each do |i|
      assert(i['snoozed'] == true)
    end
  end

  it 'with mention_ids param, it should only snooze mention ids' do
    put :snooze, format: :json, params: { mention_ids: [ my_mention.id ] }
    assert_response 200
    assert(my_mention.reload.snoozed? == true)
    assert(my_mention_2.reload.snoozed? == false)
    assert(other_mention.reload.snoozed? == false)
    json = JSON.parse(response.body)
    assert(json.size == 1)
    ids = json.map { |i| i['mention_id'] }
    assert(ids == [ my_mention.id ])
    json.each do |i|
      assert(i['snoozed'] == true)
    end
  end

  it 'it should unsnooze all mentions' do
    put :snooze, format: :json
    put :unsnooze, format: :json
    assert_response 200
    assert(my_mention.reload.snoozed? == false)
    assert(my_mention_2.reload.snoozed? == false)
    assert(other_mention.reload.snoozed? == false)
    json = JSON.parse(response.body)
    assert(json.size == 2)
    ids = json.map { |i| i['mention_id'] }
    assert(ids == [ my_mention.id, my_mention_2.id ])
    json.each do |i|
      assert(i['snoozed'] == false)
    end
  end

  it 'with mention_ids param, it should unsnooze only mention ids' do
    put :snooze, format: :json
    put :unsnooze, format: :json, params: { mention_ids: [ my_mention.id ] }
    assert_response 200
    assert(my_mention.reload.snoozed? == false)
    assert(my_mention_2.reload.snoozed? == true)
    assert(other_mention.reload.snoozed? == false)
    json = JSON.parse(response.body)
    assert(json.size == 1)
    ids = json.map { |i| i['mention_id'] }
    assert(ids == [ my_mention.id ])
    json.each do |i|
      assert(i['snoozed'] == false)
    end
  end

end


describe Api::MentionsController, "GET #index" do
  let(:chat_user1) { create(:user, current_property_role: Role.gm) }
  let(:chat_user2) { create(:user, current_property_role: Role.gm) }
  let(:chat) { create(:chat, created_by: @user, property_id: @property.id, users: [ chat_user1, @user, chat_user2 ]) }
  let(:chat_msg) { create(:chat_message, chat_id: chat.id, sender: chat_user1, property: @property) }

  let(:my_mention_checked) { create(:mention, user_id: @api_key.user_id, status: 'checked', mentionable: chat_msg) }
  let(:my_mention_not_checked) { create(:mention, user_id: @api_key.user_id, status: 'not_checked', mentionable: chat_msg) }
  let(:my_mention) { create(:mention, user_id: @api_key.user_id, mentionable: chat_msg) }
  let(:other_mention) { create(:mention, user_id: chat_user2.id, mentionable: chat_msg) }

  let(:chat_in_other_property) { create(:chat, created_by: @user, users: [ chat_user1, @user, chat_user2 ]) }
  let(:chat_msg_in_other_property) { create(:chat_message, chat_id: chat_in_other_property.id, sender: chat_user1, property: chat_in_other_property.property) }
  let(:my_mention_in_other_property) { create(:mention, user_id: @api_key.user_id, mentionable: chat_msg_in_other_property) }
  let(:other_mention_in_other_property) { create(:mention, user_id: chat_user2.id, mentionable: chat_msg_in_other_property) }

  before 'set headers' do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
  end

  describe 'when there is a mention at me and other' do
    before do
      my_mention
      my_mention_in_other_property
      other_mention
      other_mention_in_other_property
    end

    it 'mentioned_user_ids include all mentioned user ids' do
      get :index, format: :json
      json = JSON.parse(response.body)
      first_mention = json[0]

      mentioned_user_ids = first_mention['mentioned_user_ids']
      mentioned_user_ids.length.must_equal 2
      assert_includes(mentioned_user_ids, my_mention.user_id)
      assert_includes(mentioned_user_ids, other_mention.user_id)
    end

    it 'only my mention is included' do
      get :index, format: :json
      json = JSON.parse(response.body)
      json.length.must_equal 1

      returned_mention_ids = json.map { |i| i['mention_id'] }
      assert_includes(returned_mention_ids, my_mention.id)
      refute_includes(returned_mention_ids, other_mention.id)

      # only my user id is included
      user_ids = json.map { |i| i['user_id'] }
      assert_includes(user_ids, @user.id)
      refute_includes(user_ids, chat_user2.id)
    end

    it 'should not include my mention in other property' do
      get :index, format: :json
      json = JSON.parse(response.body)
      json.length.must_equal 1
      returned_mention_ids = json.map { |i| i['mention_id'] }
      assert_includes(returned_mention_ids, my_mention.id)
      refute_includes(returned_mention_ids, my_mention_in_other_property.id)
    end

    it 'content object check' do
      get :index, format: :json
      json = JSON.parse(response.body)
      first_mention = json[0]
      content = first_mention['content']
      assert_kind_of(Hash, content)
      expected_keys = ["content_id", "parent_content_id", "content_data", "content_type", "content_type_id", "content_type_name", "content_image", "created_by", "room_id", "room_number"]
      assert(content.keys.sort == expected_keys.sort)
      content['content_id'].must_equal chat_msg.id
      content['content_data'].must_equal chat_msg.message
      content['content_type'].must_equal chat.chat_type
      content['content_type_id'].must_equal chat.id
      content['content_type_name'].must_equal chat.name
      content['content_image'].must_equal ''

      created_by = content['created_by']
      assert_kind_of(Hash, created_by)
      created_by['id'].must_equal chat_msg.sender.id
      created_by['name'].must_equal chat_msg.sender.name
      created_by['avatar'].must_equal chat_msg.sender.avatar.url
      created_by['role'].must_equal chat_msg.sender.current_property_user_role.try(:role).try(:name)
    end

    it do
      get :index, format: :json
      json = JSON.parse(response.body)
      json.length.must_equal 1

      # mention object check
      first_mention = json[0]
      first_mention['user_id'].must_equal @user.id
      first_mention['status'].must_equal 'not_checked'
      first_mention['mention_type'].must_equal 'chat_mention'
      first_mention['mention_id'].must_equal my_mention.id
      first_mention['acknowledged_by_me'].must_equal false

      assert_not_nil(first_mention['created_at'])
      assert_not_nil(first_mention['updated_at'])
    end

    it 'acknowledged_by_me key check' do
      my_mention.mentionable.acknowledgements.create(user: @user)
      assert(my_mention.acknowledged_by?(@user))
      get :index, format: :json
      json = JSON.parse(response.body)
      first_mention = json[0]
      first_mention['acknowledged_by_me'].must_equal true
    end
  end

  describe 'when there is a checked and not_checked mention' do
    before do
      my_mention_checked
      my_mention_not_checked
    end

    it 'only returns not_checked mention' do
      get :index, format: :json
      json = JSON.parse(response.body)
      json.length.must_equal 1

      returned_mention_ids = json.map { |i| i['mention_id'] }
      assert_includes(returned_mention_ids, my_mention_not_checked.id)
      refute_includes(returned_mention_ids, my_mention_checked.id)
    end

    it 'returns all if option is given' do
      get :index, format: :json, params: { include_checked: true }
      json = JSON.parse(response.body)
      json.length.must_equal 2

      returned_mention_ids = json.map { |i| i['mention_id'] }
      assert_includes(returned_mention_ids, my_mention_not_checked.id)
      assert_includes(returned_mention_ids, my_mention_checked.id)
    end
  end

  describe "when there is a feed mention" do
    let(:parent_feed) { create(:engage_message, property_id: @property.id) }
    let(:feed) { create(:engage_message, property_id: @property.id, parent_id: parent_feed.id) }
    let(:feed_in_other_property) { create(:engage_message) }
    let(:my_feed_mention) { create(:mention, user_id: @api_key.user_id, mentionable: feed) }
    let(:my_feed_mention_in_other_property) { create(:mention, user_id: @api_key.user_id, mentionable: feed_in_other_property) }

    before do
      my_feed_mention
      my_feed_mention_in_other_property
    end

    it 'check json' do
      get :index, format: :json
      json = JSON.parse(response.body)
      json.length.must_equal 1
      i = json.first
      assert_includes(i['mentioned_user_ids'], @api_key.user_id)
      assert(i['mention_type'], 'feed_mention')
      assert(i['status'], 'not_checked')
      content = i['content']
      assert(content['content_id'], feed.id)
      assert(content['content_data'], feed.body)
      assert(content['content_type_id'] == nil)
      assert(content['content_type_name'] == nil)
      assert(content['parent_content_id'] == parent_feed.id)
    end

    it do
      get :index, format: :json
      json = JSON.parse(response.body)
      json.length.must_equal 1
      mention_ids = json.map { |i| i['mention_id'] }
      assert_includes(mention_ids, my_feed_mention.id)
      refute_includes(mention_ids, my_feed_mention_in_other_property.id)
    end
  end
end
