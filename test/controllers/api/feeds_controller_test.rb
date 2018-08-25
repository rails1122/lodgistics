require 'test_helper'

describe Api::FeedsController, 'GET #index' do
  before do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
  end

  describe 'Without property token' do
    it 'should return 400 error' do
      get :index, format: :json
      assert_response :bad_request
    end

    it 'should return 400 when user does not have access' do
      @request.headers['HTTP_PROPERTY_TOKEN'] = create(:property).token
      get :index, format: :json
      assert_response :bad_request
    end
  end

  describe 'With property token' do
    let(:current_time) { Date.today }

    before do
      Timecop.freeze(current_time)
      @feeds_created_1_day_ago = []
      5.times { |index| dt = 1.days.ago.beginning_of_day + index * 1.hours; @feeds_created_1_day_ago << create(:engage_message, created_at: dt, updated_at: dt, property_id: @property.id) }
      @feeds_created_today = []
      10.times { |index| @feeds_created_today << create(:engage_message, property_id: @property.id) }
      @feeds_created_today_for_other_property = []
      5.times { |index| @feeds_created_today_for_other_property << create(:engage_message) }
      @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    end

    it 'should return today feeds' do
      get :index, format: :json
      assert_response :success
      json = JSON.parse(response.body)
      item = json.first
      expected_fields = [
          "id", "title", "body", "created_at", "updated_at", "mentioned_user_ids", "comments_count",
          "created_by", "image_url", "image_height", "image_width",
          "broadcast_start", "broadcast_end", "room_id", "room_number", "follow_up_start", "follow_up_end", "completed_at", "completed_by",
          "work_order_id", "work_order_url", "work_order", "created_by_system"
      ].sort

      item.keys.sort.must_equal expected_fields
      assert(item['created_by'].keys.sort == ["id", "name", "role", "title", "avatar", "avatar_img_url"].sort)
    end

    it 'should return only today feeds for given property' do
      get :index, format: :json
      assert_response :success
      api_response.count.must_equal @feeds_created_today.length
      feed_ids_in_resp = api_response.map { |i| i['id'] }.sort
      today_feed_ids = @feeds_created_today.map(&:id).sort
      assert(feed_ids_in_resp == today_feed_ids)
    end

    it 'should not include feeds for other property' do
      get :index, format: :json
      assert_response :success
      feed_ids_in_resp = api_response.map { |i| i['id'] }.sort
      other_property_feed_ids = @feeds_created_today_for_other_property.map(&:id).sort
      other_property_feed_ids.each do |i|
        refute_includes(feed_ids_in_resp, i)
      end
    end

    it 'should return feeds created today' do
      get :index, format: :json
      assert_response :success
      api_response.count.must_equal @feeds_created_today.length
    end

    it 'should return feeds in date range - start of day and end of day' do
      start_date = (current_time - 1.day).to_date
      end_date  = current_time.to_date
      get :index, format: :json, params: {
        start_date: start_date.to_s,
        end_date: end_date.to_s
      }
      assert_response :success
      api_response.count.must_equal (@feeds_created_1_day_ago.size + @feeds_created_today.size)
      created_at_list = api_response.map { |i| i['created_at'] }
      created_at_list.each do |i|
        d = DateTime.parse(i)
        assert(d >= start_date.beginning_of_day)
        assert(d <= end_date.end_of_day)
      end
    end

    it 'should return feeds in datetime range' do
      start_datetime = @feeds_created_1_day_ago[0].updated_at
      end_datetime = @feeds_created_1_day_ago[2].updated_at
      get :index, format: :json, params: {
        start_datetime: start_datetime.to_s,
        end_datetime: end_datetime.to_s
      }
      assert_response :success
      api_response.count.must_equal (2)
    end

    it "should just return today's feed if only end_date is give" do
      end_date  = current_time.to_date
      get :index, format: :json, params: { end_date: end_date.to_s }
      assert_response :success
      api_response.count.must_equal @feeds_created_today.length
      feed_ids_in_resp = api_response.map { |i| i['id'] }.sort
      today_feed_ids = @feeds_created_today.map(&:id).sort
      assert(feed_ids_in_resp == today_feed_ids)
    end

    it 'should return no feed if there is no updated feed' do
      start_date = (current_time - 1.day).to_date
      end_date  = current_time.to_date
      d = @feeds_created_today.last.created_at.iso8601(9)
      get :index, format: :json, params: {
        start_date: start_date.to_s,
        end_date: end_date.to_s,
        updated_after: d
      }
      assert_response :success
      json = JSON.parse(response.body)
      assert(json.count == 0)
    end

    describe "if there is an updated feed" do
      let(:last_created_at) { @feeds_created_today.last.created_at }
      let(:last_updated_at) { last_created_at + 1.minute }

      before do
        Timecop.freeze(last_updated_at)
        @feeds_created_today.last.update(title: 'new title')
      end

      it 'should return only updated feed between start and end date' do
        t = last_updated_at - 1.second
        Timecop.freeze(t)
        d = t.iso8601(9)
        get :index, format: :json, params: {
          updated_after: d
        }
        assert_response :success
        json = JSON.parse(response.body)
        assert(json.count == 1)
      end
    end

    describe "given follow up feeds" do
      before do
        @follow_up = create(:engage_message, property_id: @property.id, follow_up_start: 2.days.ago.to_date, follow_up_end: 1.days.from_now.to_date, created_at: 1.hours.from_now)
      end

      it "should return with follow up message for today" do
        get :index, format: :json, params: {
          start_date: current_time.to_date,
          end_date: current_time.to_date
        }
        assert_response :success
        api_response.count.must_equal 11
        api_response.last['id'].must_equal @follow_up.id
      end

      it 'should place follow up at the first' do
        get :index, format: :json, params: {
          start_date: 1.days.ago.to_date,
          end_date: current_time.to_date
        }
        assert_response :success
        api_response.count.must_equal 17
        api_response[10]['id'].must_equal @follow_up.id
        api_response[11]['id'].must_equal @follow_up.id
      end

      it 'should show for all follow up dates' do
        get :index, format: :json, params: {
          start_date: 1.days.ago.to_date,
          end_date: 1.days.from_now.to_date
        }
        assert_response :success
        api_response.count.must_equal 18
      end
    end
  end

  after do
    Timecop.return
  end
end

describe Api::FeedsController, "GET #broadcasts" do
  before do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token

    @messages = create_list(:engage_message, 5, property_id: @property.id)
    @broadcast1 = create(:engage_message, property_id: @property.id, broadcast_start: 3.days.ago, broadcast_end: 4.days.from_now)
    @broadcast2 = create(:engage_message, property_id: @property.id, broadcast_start: 2.days.ago, broadcast_end: 5.days.from_now)
  end

  it "should not list normal messages" do
    get :broadcasts, format: :json
    assert_response :success
    api_response.count.must_equal 2
  end

  it "should list specific date broadcasts" do
    get :broadcasts, format: :json, params: {
        date: Time.current.to_date.to_s
    }
    assert_response :success
    api_response.count.must_equal 2

    get :broadcasts, format: :json, params: {
        date: 3.days.ago.to_date.to_s
    }
    assert_response :success
    api_response.count.must_equal 1

    get :broadcasts, format: :json, params: {
        date: 5.days.from_now.to_date.to_s
    }
    assert_response :success
    api_response.count.must_equal 1
  end

  it "should return broadcast information" do
    get :broadcasts, format: :json
    assert_response :success

    api_response.count.must_equal 2
    api_response[0]['id'].must_equal @broadcast1.id
    api_response[0]['body'].must_equal @broadcast1.body
    api_response[0]['broadcast_start'].must_equal @broadcast1.broadcast_start.to_s
    api_response[0]['broadcast_end'].must_equal @broadcast1.broadcast_end.to_s
  end
end

describe Api::FeedsController, "GET #show" do
  before do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token

    @feed_for_my_property = create(:engage_message, property_id: @property.id)
    @feed_for_other_property = create(:engage_message)

    @reply_feeds_for_my_property_feed = []
    5.times { |index| @reply_feeds_for_my_property_feed << create(:engage_message, parent_id: @feed_for_my_property.id, property_id: @property.id) }
  end

  it do
    last_feed = Engage::Message.last
    get :show, format: :json, params: { id: last_feed.id }
    assert_response :success
    json = JSON.parse(response.body)
    expected_fields = [
      "id", "title", "body", "created_at", "updated_at", "mentioned_user_ids", "comments_count",
      "created_by", "image_url", "image_height", "image_width", "replies",
      "broadcast_start", "broadcast_end", "room_id", "room_number", "follow_up_start", "follow_up_end", "completed_at", "completed_by",
      "work_order_id", "work_order_url", "work_order", "created_by_system"
    ].sort

    json.keys.sort.must_equal expected_fields
    assert(json['created_by'].keys.sort == ["id", "name", "role", "title", "avatar", "avatar_img_url"].sort)
  end

  it 'should return reply feeds for my property feed' do
    get :show, format: :json, params: { id: @feed_for_my_property.id }
    assert_response :success
    api_response['replies'].count.must_equal @reply_feeds_for_my_property_feed.length
  end
end

describe Api::FeedsController, "POST #create" do
  let(:rpush_apns_app) { create(:rpush_apns_app) }
  let(:rpush_gcm_app) { create(:rpush_gcm_app) }

  before do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    rpush_apns_app
    rpush_gcm_app
  end

  it do
    now = DateTime.now
    Timecop.freeze(now)
    # user create a parent post
    post :create, format: :json, params: { feed: {
        body: 'This is test message',
        image_url: 'http://placekitten.com/320/200?image=1',
        image_height: 200,
        image_width: 320
      }
    }
    parent_post = Engage::Message.last
    assert(Engage::Message.count == 1)

    # user_1 create a reply post
    now = now + 1.second
    Timecop.freeze(now)
    replying_user_1 = create(:user_with_api_key)
    @request.headers['HTTP_AUTHORIZATION'] = replying_user_1.api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    post :create, format: :json, params: {
      feed: {
        body: 'This is reply feed',
        parent_id: parent_post.id
      }
    }
    reply_1 = Engage::Message.last
    assert(Engage::Message.count == 2)

    # user_2 create a reply post
    now = now + 1.second
    Timecop.freeze(now)
    replying_user_2 = create(:user_with_api_key)
    @request.headers['HTTP_AUTHORIZATION'] = replying_user_2.api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    post :create, format: :json, params: {
      feed: {
        body: 'This is reply feed',
        parent_id: parent_post.id
      }
    }
    reply_2 = Engage::Message.last
    assert(Engage::Message.count == 3)

    # user_3 create a reply post
    now = now + 1.second
    Timecop.freeze(now)
    replying_user_3 = create(:user_with_api_key)
    @request.headers['HTTP_AUTHORIZATION'] = replying_user_3.api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    post :create, format: :json, params: {
      feed: {
        body: 'This is reply feed',
        parent_id: parent_post.id
      }
    }
    reply_3 = Engage::Message.last
    assert(Engage::Message.count == 4)

    # user list feed
    now = now + 1.second
    Timecop.freeze(now)

    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    get :show, format: :json, params: { id: parent_post.id }
    json = JSON.parse(response.body)

    # check reply count
    replies = json['replies']
    assert(replies.size == 3)

    # check replies are in desc order
    reply_ids = replies.map { |i| i['id'] }
    assert(reply_ids == [ reply_3.id, reply_2.id, reply_1.id ])

    Timecop.return
  end

  it 'should return with new message' do
    last_count = Engage::Message.count
    post :create, format: :json, params: { feed: {
        body: 'This is test message',
        image_url: 'http://placekitten.com/320/200?image=1',
        image_height: 200,
        image_width: 320
      }
    }
    assert_response 201
    api_response['body'].must_equal 'This is test message'
    api_response['created_by']['name'].must_equal @user.name
    api_response['mentioned_user_ids'].length.must_equal 0

    new_count = Engage::Message.count
    (last_count + 1).must_equal new_count
    last_item = Engage::Message.last
    assert(last_item.property_id == @property.id)
    assert(last_item.body == 'This is test message')
    assert(last_item.image_height == 200)
    assert(last_item.image_width == 320)
  end

  it 'should return 422 status on empty parameter' do
    last_count = Engage::Message.count
    post :create, format: :json, params: { feed: { body: '' } }
    assert_response 422
    new_count = Engage::Message.count
    (last_count).must_equal new_count
  end

  describe 'when there is another user in property' do
    before do
      @another_user_in_property = create(:user)
      assert_includes(@property.users, @another_user_in_property)
      assert_includes(@property.users, @user)
    end

    it 'should create in_app_notifications for all users in property, excluding me' do
      post :create, format: :json, params: { feed: {
          body: 'This is test message',
        }
      }
      assert_response 201
      in_app_notis = InAppNotification.all
      recipient_user_ids = in_app_notis.map(&:recipient_user_id)
      refute_includes(recipient_user_ids, @user.id)
      assert_includes(recipient_user_ids, @another_user_in_property.id)
    end

    it 'check in_app_notification data' do
      post :create, format: :json, params: { feed: {
          body: 'This is test message',
        }
      }
      assert_response 201
      in_app_noti = InAppNotification.first
      last_feed = Engage::Message.last
      assert(in_app_noti.property_id == last_feed.property_id)
      assert(in_app_noti.notification_type == 'new_feed')
      assert(in_app_noti.recipient_user_id == @another_user_in_property.id)
      assert(in_app_noti.data == { "message" => "New Guest Logs" })
    end
  end

  describe "for reply feed" do
    let(:parent_feed_user) { create(:user) }
    let(:parent_feed_user_device) { create(:device, user: parent_feed_user, platform: 'ios') }
    let(:parent_feed) { create(:engage_message, created_by_id: parent_feed_user.id) }

    before do
      parent_feed_user_device
    end

    it 'should create reply comment' do
      post :create, format: :json, params: {
        feed: {
          body: 'This is reply feed',
          parent_id: parent_feed.id
        }
      }
      assert_response 201
      parent_feed.reload
      parent_feed.replies.count.must_equal 1
    end

    it 'should update updated_at field of parent feed' do
      old_updated_at = parent_feed.updated_at
      Timecop.freeze(old_updated_at + 1.minute)
      post :create, format: :json, params: {
        feed: {
          body: 'This is reply feed',
          parent_id: parent_feed.id
        }
      }
      assert_response 201
      parent_feed.reload
      assert(parent_feed.updated_at.to_i != old_updated_at.to_i)
      Timecop.return
    end

    it 'should generate a notification for parent feed creator' do
      post :create, format: :json, params: {
        feed: {
          body: 'This is reply feed',
          parent_id: parent_feed.id
        }
      }
      assert_response 201
      # num of parent feed user with notification enabled + num of users in property - 1 (feed writer)
      expected_count = 1 + Engage::Message.last.property.users.size - 1
      assert(Rpush::Apns::Notification.count == expected_count)
    end

    describe "when parent feed creator has feed post notification disabled" do
      before do
        parent_feed.created_by.push_notification_setting.update(feed_post_notification_enabled: false)
      end

      it do
        post :create, format: :json, params: {
          feed: {
            body: 'This is reply feed',
            parent_id: parent_feed.id
          }
        }
        assert_response 201
        # 0 (num of parent feed user with notification enabled) + num of users in property - 1 (feed writer)
        expected_count = 0 + Engage::Message.last.property.users.size - 1
        assert(Rpush::Apns::Notification.count == expected_count)
      end
    end

    describe "when there is android device token associated with user" do
      let(:parent_feed_user_device_android) { create(:device, user: parent_feed_user, platform: 'android') }

      before do
        parent_feed_user_device_android
      end

      it 'should generate a notification for parent feed creator' do
        post :create, format: :json, params: {
          feed: {
            body: 'This is reply feed',
            parent_id: parent_feed.id
          }
        }
        assert_response 201
        # num of parent feed user + num of users in property - 1 (feed writer)
        expected_count = 1 + Engage::Message.last.property.users.size - 1
        assert(Rpush::Gcm::Notification.count == expected_count)
      end

      it do
        post :create, format: :json, params: {
          feed: {
            body: 'This is reply feed',
            mentioned_user_ids: [ parent_feed_user.id ]
          }
        }
        assert_response 201
        # num of parent feed user + num of users in property - 1 (feed writer)
        assert(Rpush::Gcm::Notification.count == Engage::Message.last.property.users.size - 1)
        last_feed = Engage::Message.last
        last_notification = Rpush::Gcm::Notification.last
        d = last_notification.data
        assert(d['type']['detail']['notified_user_mention_id'] == last_feed.mentions.where(user_id: parent_feed_user.id).first.id)
      end
    end

    it 'notification record alert data check' do
      post :create, format: :json, params: {
        feed: {
          body: 'This is reply feed',
          parent_id: parent_feed.id
        }
      }
      last_notification = Rpush::Apns::Notification.last
      last_feed = Engage::Message.last
      #msg =  "#{last_feed.created_by.try(:name)} commented on your log post:\n#{last_feed.body}"
      msg = "#{last_feed.created_by.try(:name)} posted :\n#{last_feed.body}"
      alert = NotificationHelper.generate_alert_for_apn(body: msg)
      data = NotificationHelper.generate_non_aps_attributes(last_feed)

      a = last_notification.alert
      assert(a['action-loc-key'] == alert['action-loc-key'])
      assert(a['body'] == alert[:body])
      d = last_notification.data
      d.deep_symbolize_keys!
      data.deep_symbolize_keys!
      assert(d[:property_token] == data[:property_token])
      assert(d[:type][:name] == data[:type][:name])
      assert(d[:type][:detail][:feed_id] == data[:type][:detail][:feed_id])
      assert(d[:type][:detail][:feed_comment_id] == data[:type][:detail][:feed_comment_id])
      assert(DateTime.parse(d[:type][:detail][:feed_created_at]).to_i == data[:type][:detail][:feed_created_at].to_i)
      assert(DateTime.parse(d[:type][:detail][:feed_comment_created_at]).to_i == data[:type][:detail][:feed_comment_created_at].to_i)
    end
  end

  it 'should return with new message' do
    last_count = Engage::Message.count
    post :create, format: :json, params: {
      feed: { body: 'This is test message' }
    }
    assert_response 201
    api_response['body'].must_equal 'This is test message'
    api_response['created_by']['name'].must_equal @user.name
    api_response['mentioned_user_ids'].length.must_equal 0

    new_count = Engage::Message.count
    (last_count + 1).must_equal new_count
    assert(Engage::Message.last.property_id == @property.id)
  end

  describe "for replying to your own feed" do
    let(:parent_feed_user) { @user }
    let(:parent_feed_user_device) { create(:device, user: parent_feed_user) }
    let(:parent_feed) { create(:engage_message, created_by_id: parent_feed_user.id) }

    before do
      parent_feed_user_device
    end

    it 'should NOT generate a notification for parent feed creator' do
      post :create, format: :json, params: {
        feed: {
          body: 'This is reply feed',
          parent_id: parent_feed.id
        }
      }
      assert_response 201
      assert(Rpush::Apns::Notification.count == 0)
    end
  end

  describe "for reply feed on a feed post that has mentioned users" do
    let(:parent_feed_user) { create(:user) }
    let(:parent_feed_user_device) { create(:device, user: parent_feed_user) }
    let(:mentioned_user_in_parent_feed) { create(:user) }
    let(:mentioned_user_device) { create(:device, user: mentioned_user_in_parent_feed) }
    let(:parent_feed) {
      f = create(:engage_message, created_by_id: parent_feed_user.id)
      f.mentions.create(user_id: mentioned_user_in_parent_feed.id)
      f
    }

    before do
      parent_feed_user_device
      mentioned_user_device
    end

    it 'should generate notifications for parent feed creator and mentioned users in that parent feed' do
       post :create, format: :json, params: {
         feed: {
           body: 'This is reply feed',
           parent_id: parent_feed.id
         }
       }
      assert_response 201
      # num of parent feed user count + num of mentioned users + num of users in property - 1 (msg writer)
      expected_count = 1 + 1 + Engage::Message.last.property.users.size - 1
      assert(Rpush::Apns::Notification.count == expected_count)
    end

    describe 'when mentioned user in the parent feed has feed post push notification off' do
      before do
        mentioned_user_in_parent_feed.push_notification_setting.update(feed_post_notification_enabled: false)
      end

      it 'should only create push notification for parent feed creator' do
        post :create, format: :json, params: {
          feed: {
            body: 'This is reply feed',
            parent_id: parent_feed.id
          }
        }
        assert_response 201
        # num of parent feed user + num of users in property - 1 (feed writer)
        expected_count = 1 + Engage::Message.last.property.users.size - 1
        assert(Rpush::Apns::Notification.count == expected_count)
      end
    end

    describe 'when mentioned user in the parent feed has snoozed mention notification' do
      before do
        parent_feed.mentions.first.set_snooze
      end

      it 'should only create push notification for parent feed creator only' do
        post :create, format: :json, params: {
          feed: {
            body: 'This is reply feed',
            parent_id: parent_feed.id
          }
        }
        assert_response 201
        # num of parent feed user + num of users in property - 1 (feed writer)
        expected_count = 1 + Engage::Message.last.property.users.size - 1
        assert(Rpush::Apns::Notification.count == expected_count)
      end
    end

    it 'notification record alert data check' do
      post :create, format: :json, params: {
        feed: {
          body: 'This is reply feed',
          parent_id: parent_feed.id
        }
      }
      last_feed = Engage::Message.last
      msg_1 =  "#{last_feed.created_by.try(:name)} commented on your log post:\n#{last_feed.body}"
      msg_2 =  "#{last_feed.created_by.try(:name)} posted :\n#{last_feed.body}"
      alert = NotificationHelper.generate_alert_for_apn(body: msg_1)
      data = NotificationHelper.generate_non_aps_attributes(last_feed)

      notifications = Rpush::Apns::Notification.all
      notifications.each do |n|
        a = n.alert
        assert(a['action-loc-key'] == alert['action-loc-key'])
        # body should be either one of msg_1 or msg_2
        assert((a['body'] == msg_1) || (a['body'] == msg_2))

        d = n.data
        d.deep_symbolize_keys!
        data.deep_symbolize_keys!
      end
    end
  end

  describe "when mentioned_user_ids parameter is given" do
    let(:user1) { create(:user) }
    let(:user1_device) { create(:device, user: user1) }

    before do
      user1_device
    end

    it 'should create mention records' do
      post :create, format: :json, params: {
        feed: {
          body: 'post with mentions',
          mentioned_user_ids: [ user1.id ]
        }
      }
      assert_response 201
      json = JSON.parse(response.body)
      assert(json['mentioned_user_ids'].length == 1)
      assert_includes(json['mentioned_user_ids'], user1.id)
      assert(Mention.count == 1)
      last_feed = Engage::Message.last
      assert(Mention.last.property_id == last_feed.property_id)
    end

    it 'should create notification record for mentioned_user' do
      post :create, format: :json, params: {
        feed: {
          body: 'post with mentions',
          mentioned_user_ids: [ user1.id ]
        }
      }
      assert_response 201
      # num of mentioned user count + num of users in property - 1 (msg writer)
      assert(Rpush::Apns::Notification.count == Engage::Message.last.property.users.size - 1)
    end

    describe 'mentioned user has feed post push notification setting disabled' do
      before do
        user1.push_notification_setting.update(feed_post_notification_enabled: false)
      end

      it 'should not create notification for mentioned_user' do
        post :create, format: :json, params: {
          feed: {
            body: 'post with mentions',
            mentioned_user_ids: [ user1.id ]
          }
        }
        assert_response 201
        # no one will receive notification
        assert(Rpush::Apns::Notification.count == 0)
      end
    end

    it 'should create rpush notification record' do
      post :create, format: :json, params: {
        feed: {
          body: 'post with mentions',
          mentioned_user_ids: [ user1.id ]
        }
      }
      assert_response 201
      last_notification = Rpush::Apns::Notification.last
      last_feed = Engage::Message.last
      msg =  "#{last_feed.created_by.try(:name)} mentioned you:\npost with mentions"
      alert = NotificationHelper.generate_alert_for_apn(body: msg)
      data = NotificationHelper.generate_non_aps_attributes(last_feed)

      a = last_notification.alert
      assert(a['action-loc-key'] == alert['action-loc-key'])
      assert(a['body'] == alert[:body])

      d = last_notification.data
      d.deep_symbolize_keys!
      data.deep_symbolize_keys!
      assert(d[:property_token] == data[:property_token])
      assert(d[:type][:name] == data[:type][:name])
      assert(d[:type][:detail][:feed_id] == data[:type][:detail][:feed_id])
      assert(DateTime.parse(d[:type][:detail][:feed_created_at]).to_i == data[:type][:detail][:feed_created_at].to_i)
      assert(d[:type][:detail][:notified_user_mention_id] == last_feed.mentions.where(user_id: user1.id).first.id)
    end
  end

  describe 'parse room number' do
    [
        'parse room number: room #2342',
        'parse room number: room 2342',
        'parse room number: room2342'
    ].each do |message|
      it "should parse room number for '#{message}'" do
        post :create, format: :json, params: {
            feed: {
                body: message
            }
        }
        assert_response 201

        api_response['room_number'].must_equal '2342'
        assert_nil api_response['room_id']
      end
    end

    it 'should link with room' do
      room = create(:room, room_number: 104, property_id: @property.id)
      post :create, format: :json, params: {
          feed: {
              body: 'parse room number: room #104'
          }
      }
      assert_response 201

      api_response['room_number'].must_equal room.room_number
      api_response['room_id'].must_equal room.id
    end
  end

  it 'should parse urls and emails as links' do
    post :create, format: :json, params: {
        feed: {
            body: 'Url Parse: http://google.com Email parse: test@example.com'
        }
    }
    assert_response 201

    api_response['body'].must_include "<a href=\"http://google.com\">http://google.com</a>"
    api_response['body'].must_include "<a href=\"mailto:test@example.com\">test@example.com</a>"
  end
end

describe Api::FeedsController, "PUT #update" do
  before do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token

    @feed = create(:engage_message, property_id: @property.id)
  end

  it 'should update broadcast params' do
    put :update, format: :json, params: {id: @feed.id, feed: {
        broadcast_start: 2.days.ago.to_date.to_s,
        broadcast_end: Time.current.to_date.to_s
    }}

    assert_response :success
    api_response['broadcast_start'].must_equal 2.days.ago.to_date.to_s
    api_response['broadcast_end'].must_equal Time.current.to_date.to_s
  end

  it 'should mark feed as completed' do
    put :update, format: :json, params: {id: @feed.id, feed: {
      complete: true
    }}

    assert_response :success
    assert_not_nil api_response['completed_at']
    assert_not_nil api_response['completed_by']
  end

  it 'should mark feed as follow up' do
    put :update, format: :json, params: {id: @feed.id, feed: {
      follow_up_start: 2.days.ago.to_date.to_s,
      follow_up_end: Time.current.to_date.to_s
    }}

    assert_response :success
    api_response['follow_up_start'].must_equal 2.days.ago.to_date.to_s
    api_response['follow_up_end'].must_equal Time.current.to_date.to_s
  end
end

describe Api::FeedsController, 'GET #follow_ups' do
  before do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token

    create_list(
      :engage_message, 3,
      property_id: @property.id,
      follow_up_start: Date.current, follow_up_end: 2.days.from_now
    )

    create_list(
      :engage_message, 5,
      property_id: @property.id,
      follow_up_start: 2.days.ago, follow_up_end: 1.days.from_now
    )
  end

  it 'should return all follow ups' do
    get :follow_ups, format: :json, params: {date: Date.current}
    api_response.length.must_equal 8

    get :follow_ups, format: :json, params: {date: 2.days.from_now}
    api_response.length.must_equal 3

    get :follow_ups, format: :json, params: {date: 2.days.ago}
    api_response.length.must_equal 5
  end
end
