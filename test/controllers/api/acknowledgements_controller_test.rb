require 'test_helper'

describe Api::AcknowledgementsController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:acknowledgement_at_me) { create(:acknowledgement, target_user: @user) }
  let(:acknowledgement_created_by_me) { create(:acknowledgement, user: @user) }
  let(:acknowledgement_at_other) { create(:acknowledgement, target_user: user1) }
  let(:acknowledgement_created_by_other) { create(:acknowledgement, user: user1) }

  it "should list acknowledgements both created by and targetted at me" do
    acknowledgement_at_me
    acknowledgement_created_by_me
    acknowledgement_at_other
    acknowledgement_created_by_other
    get :index, format: :json
    assert_response 200
    json = JSON.parse(response.body)
    ids = json.map { |i| i['id'] }
    assert_includes(ids, acknowledgement_at_me.id)
    assert_includes(ids, acknowledgement_created_by_me.id)
    refute_includes(ids, acknowledgement_at_other.id)
    refute_includes(ids, acknowledgement_created_by_other.id)
    assert(json.first.keys.sort == [ 'id', 'user_id', 'target_user_id', 'created_at', 'updated_at', 'checked_at', 'acknowledeable_id', 'acknowledeable_type' ].sort)
  end
end

describe Api::AcknowledgementsController, "GET #received" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:acknowledgement_at_me) { create(:acknowledgement, target_user: @user) }
  let(:acknowledgement_created_by_me) { create(:acknowledgement, user: @user) }
  let(:acknowledgement_at_other) { create(:acknowledgement, target_user: user1) }
  let(:acknowledgement_created_by_other) { create(:acknowledgement, user: user1) }

  it "should list acknowledgements targetted at me" do
    acknowledgement_at_me
    acknowledgement_created_by_me
    acknowledgement_at_other
    acknowledgement_created_by_other
    get :received, format: :json
    assert_response 200
    json = JSON.parse(response.body)
    ids = json.map { |i| i['id'] }
    assert_includes(ids, acknowledgement_at_me.id)
    refute_includes(ids, acknowledgement_created_by_me.id)
    refute_includes(ids, acknowledgement_at_other.id)
    refute_includes(ids, acknowledgement_created_by_other.id)
    assert(json.first.keys.sort == [ 'id', 'user_id', 'target_user_id', 'created_at', 'updated_at', 'checked_at', 'acknowledeable_id', 'acknowledeable_type' ].sort)
  end
end

describe Api::AcknowledgementsController, "GET #sent" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:acknowledgement_at_me) { create(:acknowledgement, target_user: @user) }
  let(:acknowledgement_created_by_me) { create(:acknowledgement, user: @user) }
  let(:acknowledgement_at_other) { create(:acknowledgement, target_user: user1) }
  let(:acknowledgement_created_by_other) { create(:acknowledgement, user: user1) }

  it "should list acknowledgements targetted at me" do
    acknowledgement_at_me
    acknowledgement_created_by_me
    acknowledgement_at_other
    acknowledgement_created_by_other
    get :sent, format: :json
    assert_response 200
    json = JSON.parse(response.body)
    ids = json.map { |i| i['id'] }
    refute_includes(ids, acknowledgement_at_me.id)
    assert_includes(ids, acknowledgement_created_by_me.id)
    refute_includes(ids, acknowledgement_at_other.id)
    refute_includes(ids, acknowledgement_created_by_other.id)
    assert(json.first.keys.sort == [ 'id', 'user_id', 'target_user_id', 'created_at', 'updated_at', 'checked_at', 'acknowledeable_id', 'acknowledeable_type' ].sort)
  end
end




describe Api::AcknowledgementsController, "GET #show" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:acknowledgement_created_by_me) { create(:acknowledgement, user: @user) }
  let(:acknowledgement_target_at_me) { create(:acknowledgement, target_user: @user) }
  let(:acknowledgement_created_by_other) { create(:acknowledgement, user: user1) }
  let(:acknowledgement_target_at_other) { create(:acknowledgement, target_user: user1) }

  it "should list acknowledgements targetted at me" do
    get :show, format: :json, params: { id: acknowledgement_created_by_me.id }
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.keys.sort == [ 'id', 'user_id', 'target_user_id', 'created_at', 'updated_at', 'checked_at', 'acknowledeable_id', 'acknowledeable_type' ].sort)
  end

  it do
    get :show, format: :json, params: { id: acknowledgement_target_at_me.id }
    assert_response 200
  end

  it do
    get :show, format: :json, params: { id: acknowledgement_created_by_other.id }
    assert_response 401
  end

  it do
    get :show, format: :json, params: { id: acknowledgement_target_at_other.id }
    assert_response 401
  end
end

describe Api::AcknowledgementsController, "POST #create" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }
  let(:mentioned_user) { create(:user, current_property_role: Role.gm) }
  let(:chat) { create(:chat, created_by: @user, property_id: @property.id, users: [ user1, @user, user2 ]) }
  let(:chat_msg) do
    create(:chat_message, chat_id: chat.id, sender: user1, property: @property)
  end

  let(:feed) {
    f = create(:engage_message, created_by_id: user1.id)
    f
  }

  let(:feed_with_mention) {
    f = create(:engage_message, created_by_id: user1.id)
    f.create_mention_records([mentioned_user.id])
    f
  }

  it "should set snoozed_at of mentions" do
    Acknowledgement.count.must_equal 0
    post :create, format: :json, params: { acknowledgement: { target_user_id: user1.id, acknowledeable_id: feed_with_mention.id, acknowledeable_type: 'Engage::Message', snooze_mention: false } }
    assert_response 200
    Acknowledgement.count.must_equal 1
    feed_with_mention.mentions.each do |mention|
      assert(mention.snoozed_at != nil)
    end
  end

  it do
    Acknowledgement.count.must_equal 0
    post :create, format: :json, params: { acknowledgement: { target_user_id: user1.id, acknowledeable_id: feed.id, acknowledeable_type: 'Engage::Message' } }
    assert_response 200
    Acknowledgement.count.must_equal 1
  end

  it do
    Acknowledgement.count.must_equal 0
    post :create, format: :json, params: { acknowledgement: { target_user_id: user2.id, acknowledeable_id: chat_msg.id, acknowledeable_type: 'ChatMessage' } }
    assert_response 200
    Acknowledgement.count.must_equal 1
    last_item = Acknowledgement.last
    assert(last_item.target_user == user2)
    assert(last_item.user == @user)
    assert(last_item.acknowledeable == chat_msg)
  end

  it do
    post :create, format: :json, params: { acknowledgement: { target_user_id: user2.id, acknowledeable_id: chat_msg.id, acknowledeable_type: 'ChatMessage' } }
    json = JSON.parse(response.body)
    assert(json.keys.sort == [ 'id', 'user_id', 'target_user_id', 'created_at', 'updated_at', 'checked_at', 'acknowledeable_id', 'acknowledeable_type' ].sort)
  end

  it 'should send notification to the acknowledged (e.g. creator of message or feed)' do
   create(:rpush_apns_app)
   create(:device, user: user1)
   post :create, format: :json, params: { acknowledgement: { target_user_id: user1.id, acknowledeable_id: chat_msg.id, acknowledeable_type: 'ChatMessage' } }
   assert(Rpush::Apns::Notification.count == 1)
   assert_match(
     "#{@user.name} has acknowedged your message, #{chat_msg.message}",
     Rpush::Apns::Notification.last.alert["body"]
   )
  end

  describe 'if target_user has ack push notification disabled' do
    it 'should not create push notification' do
      create(:rpush_apns_app)
      create(:device, user: user1)
      user1.push_notification_setting.update(acknowledged_notification_enabled: false)
      post :create, format: :json, params: { acknowledgement: { target_user_id: user1.id, acknowledeable_id: chat_msg.id, acknowledeable_type: 'ChatMessage' } }
      assert(Rpush::Apns::Notification.count == 0)
    end
  end
end
