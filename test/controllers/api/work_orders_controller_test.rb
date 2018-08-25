require 'test_helper'

work_order_fields = [
    :id, :property_id, :description, :priority, :status, :due_to_date, :assigned_to_id,
    :maintainable_type, :maintainable_id, :opened_by_user_id, :created_at, :updated_at, :closed_by_user_id,
    :first_img_url, :second_img_url, :work_order_url, :location_detail, :closed_at, :closed,
    :opened_at, :maintenance_checklist_item_id, :other_maintainable_location
].sort

describe Api::WorkOrdersController, "POST #create permission" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it 'should not allow to create without permission' do
    post :create, format: :json, params: { work_order: { description: 'work order test', first_img_url: 'img_url_1', second_img_url: 'img_url_2'} }
    assert_response :forbidden
  end

  it 'should create work order with permission' do
    create(:permission, role: Role.gm, department: @user.departments.first, permission_attribute: attribute('Create WOs'))
    post :create, format: :json, params: { work_order: { description: 'work order test', first_img_url: 'img_url_1', second_img_url: 'img_url_2'} }
    assert_response :ok
  end
end

describe Api::WorkOrdersController, "POST #create" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    create(:permission, role: Role.gm, department: @user.departments.first, permission_attribute: attribute('Create WOs'))
  end

  it 'should create work order' do
    post :create, format: :json, params: { work_order: { description: 'work order test', first_img_url: 'img_url_1', second_img_url: 'img_url_2'} }
    json = JSON.parse(response.body)
    assert(Maintenance::WorkOrder.count == 1)
    last_item = Maintenance::WorkOrder.last
    assert(last_item.opened_by == @user)
    assert(last_item.assigned_to_id == -2)
    assert(last_item.first_img_url == 'img_url_1')
    assert(last_item.second_img_url == 'img_url_2')
    assert(last_item.opened_at.to_i == last_item.created_at.to_i)
    assert(last_item.checklist_item_maintenance_id.present?)
    assert(json.symbolize_keys.keys.sort == work_order_fields)
    assert(json.symbolize_keys[:work_order_url] == last_item.resource_url)
  end

  it 'should create Maintenance::ChecklistItemMaintenance record' do
    post :create, format: :json, params: { work_order: { description: 'work order test', maintenance_checklist_item_id: 123} }
    assert_response :ok
    last_item = Maintenance::WorkOrder.last
    assert(last_item.opened_at.to_i == last_item.created_at.to_i)
    assert(Maintenance::ChecklistItemMaintenance.count == 1)
    assert(Maintenance::ChecklistItemMaintenance.last.maintenance_checklist_item_id == 123)
  end

  it 'should generate 1 in app notification when there is no assigned user' do
    post :create, format: :json, params: { work_order: { description: 'work order test', first_img_url: 'img_url_1', second_img_url: 'img_url_2'} }
    assert_response :ok
    assert(InAppNotification.count == 1)
    assert(InAppNotification.last.recipient_user_id == @user.id)
  end

  it 'should generate 2 in app notification when there is an assigned user' do
    user1 = create(:user, current_property_role: Role.gm)
    post :create, format: :json, params: { work_order: { description: 'work order test', first_img_url: 'img_url_1', second_img_url: 'img_url_2', assigned_to_id: user1.id} }
    assert_response :ok
    assert(InAppNotification.count == 2)
  end

  it 'should add Maintenance:: to maintainable_type' do
    post :create, format: :json, params: { work_order: { description: 'work order test', maintainable_type: 'Room'} }
    json = JSON.parse(response.body)
    last_item = Maintenance::WorkOrder.last
    assert(last_item.maintainable_type == "Maintenance::Room")
    assert(json['maintainable_type'] == 'Room')
  end

  it 'should create work order with Other maintainable_type' do
    post :create, format: :json, params: { work_order: { description: 'Other maintainable_type', maintainable_type: 'Other', other_maintainable_location: 'Warehouse' } }
    json = JSON.parse(response.body)
    last_item = Maintenance::WorkOrder.last
    assert(last_item.maintainable_type == 'Other')
    assert(last_item.other_maintainable_location == 'Warehouse')
  end

  it do
    post :create, format: :json, params: { work_order: { description: 'work order test', due_to_date: '2017-09-29'} }
    last_item = Maintenance::WorkOrder.last
    assert(last_item.due_to_date == Date.parse('2017-09-29'))
  end

  it 'should create work order from feed' do
    feed = FactoryGirl.create(:engage_message, property: @property)
    post :create, format: :json, params: { feed_id: feed.id, work_order: { description: 'work order test'} }
    assert(Maintenance::WorkOrder.count == 1)
    last_item = Maintenance::WorkOrder.last
    assert(feed.reload.work_order_id == last_item.id)
  end

  it 'should return 404 status if feed id does not exist' do
    post :create, format: :json, params: { feed_id: 1234, work_order: { description: 'work order test'} }
    assert_response 404
  end

  it 'should create work order from chat_message' do
    user1 = create(:user, current_property_role: Role.gm)
    room = create(:room)
    chat_i_am_in = create(:chat, user_ids: [ @user.id, user1.id ], property: @property)
    chat_msg = create(:chat_message, chat: chat_i_am_in, sender: user1, property: @property)
    post :create, format: :json, params: { chat_message_id: chat_msg.id, work_order: { description: 'work order test', priority: 'm', status: 'open', 'assigned_to_id': user1.id, maintainable_id: room.id, maintainable_type: 'Room' } }
    assert(Maintenance::WorkOrder.count == 1)
    last_item = Maintenance::WorkOrder.last
    assert(chat_msg.reload.work_order_id == last_item.id)
  end

  it 'should create work order from chat_message' do
    user1 = create(:user, current_property_role: Role.gm)
    chat_i_am_in = create(:chat, user_ids: [ @user.id, user1.id ], property: @property)
    chat_msg = create(:chat_message, chat: chat_i_am_in, sender: user1, property: @property)
    post :create, format: :json, params: { chat_message_id: chat_msg.id, work_order: { description: 'work order test', due_to_date: '' } }
    assert(Maintenance::WorkOrder.count == 1)
    last_item = Maintenance::WorkOrder.last
    assert(chat_msg.reload.work_order_id == last_item.id)
  end
end

describe Api::WorkOrdersController, "GET #index permissions" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  it 'should not get work orders without permission' do
    get :index, format: :json
    assert_response :forbidden
  end

  it 'should get work orders with permission' do
    permission = build(:permission, role: Role.gm, department: @user.departments.first, permission_attribute: attribute('WO Listing'))
    permission.options = [:all]
    permission.save
    get :index, format: :json
    assert_response :ok
  end
end

describe Api::WorkOrdersController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token

    create(:permission, role: Role.gm, department: @user.departments.first, permission_attribute: attribute('Create WOs'))
    permission = build(:permission, role: Role.gm, department: @user.departments.first, permission_attribute: attribute('WO Listing'))
    permission.options = [:all]
    permission.save

    post :create, format: :json, params: { work_order: { description: 'work order test'} }
    @wo_created_by_me = Maintenance::WorkOrder.last
    post :create, format: :json, params: { work_order: { description: 'work order test'} }
    @closed_wo_created_by_me = Maintenance::WorkOrder.last
    @closed_wo_created_by_me.close_by(@user)
    @wo_created_by_another_user = FactoryGirl.create(:work_order, property: @property)
  end

  it do
    get :index, format: :json
    json = JSON.parse(response.body)
    assert(json.first.symbolize_keys.keys.sort == work_order_fields)
  end

  it 'should only return active if no filter parameter is given' do
    get :index, format: :json
    json = JSON.parse(response.body)
    ids = json.map { |i| i['id'] }
    expected_ids = [ @wo_created_by_me.id, @wo_created_by_another_user.id ]
    assert(ids.sort == expected_ids.sort)
  end

  it 'should only return active if filter parameter is given with status = active' do
    get :index, format: :json, params: { status: 'active' }
    json = JSON.parse(response.body)
    ids = json.map { |i| i['id'] }
    expected_ids = [ @wo_created_by_me.id, @wo_created_by_another_user.id ]
    assert(ids.sort == expected_ids.sort)
  end

  it 'should only return active if filter parameter is given with status = closed' do
    get :index, format: :json, params: { status: 'closed' }
    json = JSON.parse(response.body)
    ids = json.map { |i| i['id'] }
    expected_ids = [ @closed_wo_created_by_me.id ]
    assert(ids.sort == expected_ids.sort)
  end

  it 'should only return active if filter parameter is given with status = opened' do
    get :index, format: :json, params: { status: 'opened' }
    json = JSON.parse(response.body)
    ids = json.map { |i| i['id'] }
    expected_ids = [ @wo_created_by_me.id, @wo_created_by_another_user.id ]
    assert(ids.sort == expected_ids.sort)
  end
end

describe Api::WorkOrdersController, "GET #show" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token

    create(:permission, role: Role.gm, department: @user.departments.first, permission_attribute: attribute('Create WOs'))
    post :create, format: :json, params: { work_order: { description: 'work order test'} }
  end

  it "" do
    last_item = Maintenance::WorkOrder.last
    get :show, params: { format: :json, id: last_item.id }
    json = JSON.parse(response.body)
    assert(json.symbolize_keys.keys.sort == work_order_fields)
  end
end

describe Api::WorkOrdersController, "PUT #close" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token

    create(:permission, role: Role.gm, department: @user.departments.first, permission_attribute: attribute('Create WOs'))
  end

  describe 'for regular work order' do
    let(:work_order_opened_by_me) { create(:work_order, opened_by_user_id: @user.id, property_id: @property.id) }

    it "should be able to change work order's status to closed" do
      put :close, params: { format: :json, id: work_order_opened_by_me.id }
      work_order_opened_by_me.reload
      assert(work_order_opened_by_me.status == Maintenance::WorkOrder::STATUS_CLOSED.to_s)
      assert(work_order_opened_by_me.closed_at.nil? == false)
      assert(work_order_opened_by_me.closed_by_user_id == @user.id)
    end

    it do
      put :close, params: { format: :json, id: work_order_opened_by_me.id }
      assert_response 200
      api_response['id'].must_equal work_order_opened_by_me.id
    end
  end

  describe 'for regular work order with assigned to me' do
    let(:work_order_creator) { create(:user) }
    let(:work_order_assigned_to_me) { create(:work_order, assigned_to_id: @user.id, property_id: @property.id) }

    it do
      put :close, params: { format: :json, id: work_order_assigned_to_me.id }
      work_order_assigned_to_me.reload
      assert(work_order_assigned_to_me.status == 'closed')
      assert(work_order_assigned_to_me.closed_at.nil? == false)
      assert(work_order_assigned_to_me.closed_by_user_id == @user.id)
    end

    it do
      put :close, params: { format: :json, id: work_order_assigned_to_me.id }
      assert_response 200
      api_response['id'].must_equal work_order_assigned_to_me.id
    end
  end

  describe 'when work order was created from a chat message' do
    let(:user1) { create(:user, current_property_role: Role.gm) }
    let(:user2) { create(:user, current_property_role: Role.gm) }
    let(:chat_i_am_in) { create(:chat, user_ids: [ @user.id, user1.id, user2.id ], property: @property) }
    let(:chat_message) { create(:chat_message, chat: chat_i_am_in, property: @property, sender: user1) }

    before do
      post :create, format: :json, params: { work_order: { description: 'work order test'}, chat_message_id: chat_message.id }
      @last_wo = Maintenance::WorkOrder.last
    end

    it "should generate a chat message notifying status update" do
      last_count = ChatMessage.count
      put :close, format: :json, params: { id: @last_wo.id }
      new_count = ChatMessage.count
      assert(new_count - last_count == 1)
      last_msg = ChatMessage.last
      assert(last_msg.message == 'Work order has been closed')
      assert(last_msg.sender_id == User.lodgistics_bot_user.id)
      assert(last_msg.chat_id == chat_i_am_in.id)
      assert(last_msg.property_id == chat_i_am_in.property_id)
    end

    it do
      put :close, format: :json, params: { id: @last_wo.id }
      assert_response 200
      api_response['id'].must_equal @last_wo.id

      chat_message_json = api_response['chat_message']
			expected = ["chat_id",
							 "created_at",
							 "id",
							 "image_url",
							 "mention_ids",
							 "mentioned_user_ids",
							 "message",
							 "read",
							 "read_by_user_ids",
							 "reads_count",
							 "responding_to_chat_message_id",
							 "room_id",
							 "room_number",
							 "sender_avatar_img_url",
							 "sender_id",
							 "updated_at",
							 "work_order",
							 "work_order_id",
							 "work_order_url"
			]
      chat_message_json.keys.sort.must_equal expected.sort
    end
  end

  describe "when work order was created from a feed post" do
    let(:feed) { create(:engage_message, property_id: @property.id) }

    before do
      post :create, format: :json, params: { feed_id: feed.id, work_order: { description: 'work order test'} }
      @last_wo = Maintenance::WorkOrder.last
      assert(Maintenance::WorkOrder.count == 1)
      last_item = Maintenance::WorkOrder.last
      assert(feed.reload.work_order_id == last_item.id)
      assert(Engage::Message.count == 1)
    end

    it "should generate a feed post notifyinng status update" do
      last_count = Engage::Message.count
      put :close, format: :json, params: { id: @last_wo.id }
      new_count = Engage::Message.count
      assert(new_count - last_count == 1)
      last_feed = Engage::Message.last
      assert(last_feed.property_id == feed.property_id)
      assert(last_feed.created_by_id == User.lodgistics_bot_user.id)
      assert(last_feed.title == 'Work order has been closed')
      assert(last_feed.body == 'Work order has been closed')
      assert(last_feed.parent_id == feed.id)
    end

    it "should update parent feed's updated at field" do
      feed_updated_at = feed.updated_at
      sleep 1
      put :close, format: :json, params: { id: @last_wo.id }
      assert(feed.reload.updated_at.to_i > feed_updated_at.to_i)
    end

    it do
      put :close, format: :json, params: { id: @last_wo.id }
      assert_response 200
      api_response['id'].must_equal @last_wo.id

      feed_post_json = api_response['feed_post']
      assert(feed_post_json.keys.sort == ["id", "title", "body", "created_at", "updated_at", "image_url", "image_width", "image_height", "work_order_id"].sort)
    end
  end
end

describe Api::WorkOrdersController, "PUT #update" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  describe 'for regular work order' do
    let(:work_order_opened_by_me) { create(:work_order, opened_by_user_id: @user.id, property_id: @property.id) }

    it "should be able to change work order's status to closed" do
      put :update, format: :json, params: { id: work_order_opened_by_me.id, work_order: { description: 'new description' } }
      assert_response 200
      work_order_opened_by_me.reload
      assert(work_order_opened_by_me.description == 'new description')
    end

    it do
      put :update, format: :json, params: { id: work_order_opened_by_me.id, work_order: { description: 'new description' } }
      json = JSON.parse(response.body)
      assert(json.symbolize_keys.keys.sort == work_order_fields)
    end

    it 'generate in app notification if assigned_to_id changes' do
      user1 = create(:user, current_property_role: Role.gm)
      put :update, format: :json, params: { id: work_order_opened_by_me.id, work_order: { description: 'new description', assigned_to_id: user1.id } }
      assert_response 200
      assert(InAppNotification.count == 1)
      assert(InAppNotification.last.recipient_user_id == user1.id)
    end

    it 'should not generate in app notification if assigned_to_id changes to nil or -2' do
      put :update, format: :json, params: { id: work_order_opened_by_me.id, work_order: { description: 'new description', assigned_to_id: -2 } }
      assert_response 200
      assert(InAppNotification.count == 0)
    end
  end
end

describe Api::WorkOrdersController, "GET #assignable_users" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    create(:user, current_property_role: Role.gm, departments: @user.departments)
    create(:user, current_property_role: Role.agm, departments: @user.departments)
  end

  describe 'when no assignable users' do
    it 'should return default users' do
      get :assignable_users, format: :json

      assert_response :ok
      json = JSON.parse(response.body)
      assert(json.size == 2)
      assert(json[0][0] == '3rd Party')
      assert(json[1][0] == 'Unassigned')
    end
  end

  describe 'when there are assignable users' do
    it 'should return all assignable users' do
      create(:permission,
             role: Role.agm,
             department: @user.departments.first,
             permission_attribute: attribute('Available to be assigned to WOs'))

      get :assignable_users, format: :json

      assert_response :ok
      json = JSON.parse(response.body)
      assert(json.size == 3)
    end
  end
end
