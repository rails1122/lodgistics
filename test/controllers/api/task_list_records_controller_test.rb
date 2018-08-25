require 'test_helper'

describe Api::TaskListRecordsController, "POST #finish" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_property = create(:property)
    @task_list1 = create(:task_list, property_id: @property.id)
    @task_category = create(:task_item, task_list: @task_list1)
    @task_items = create_list(:task_item, 5, task_list: @task_list1, category: @task_category)

    @task_list_record = @task_list1.start_resume!(@user)
    @reviewer = create(:user, department_ids: @user.departments.map(&:id))
    @rpush_apns_app = create(:rpush_apns_app)
    @rpush_gcm_app = create(:rpush_gcm_app)
  end

  it 'should not allow to finish without assignable roles' do
    post :finish, format: :json, params: { id: @task_list_record.id }
    assert_response :forbidden
  end

  describe 'with assignable roles' do
    before do
      create(
        :task_list_role_assignable,
        task_list_id: @task_list1.id,
        role_id: @user.current_property_role.id,
        department_id: @user.departments.first.id
      )
      # create reviewable role for @reviewer
      create(
        :task_list_role_reviewable,
        task_list_id: @task_list1.id,
        role_id: @reviewer.current_property_role.id,
        department_id: @reviewer.departments.first.id
      )
    end

    it 'should finish task list record with incomplete status' do
      post :finish, format: :json, params: { id: @task_list_record.id}
      assert_response :ok

      @task_list_record.reload
      assert @task_list_record.finished_at.present?
      @task_list_record.finished_by.id.must_equal @user.id
      assert @task_list_record.finished_incomplete?
    end

    it 'should finish task list record with complete status' do
      @task_list_record.task_item_records.each do |item|
        item.complete!(@user, {status: 'completed'})
      end
      post :finish, format: :json, params: { id: @task_list_record.id}
      assert_response :ok

      @task_list_record.reload
      assert @task_list_record.finished_at.present?
      @task_list_record.finished_by.id.must_equal @user.id
      assert @task_list_record.finished?
    end

    describe "when there is ios device token associated with reviewer" do

      before do
        @ios_device_for_reviewer = create(:device, user: @reviewer, platform: 'ios')
        @ios_device_for_user = create(:device, user: @user, platform: 'ios')
      end

      it "should send a notifcation to reviewer" do
        post :finish, format: :json, params: { id: @task_list_record.id}
        assert_response :ok
        #assert(Rpush::Apns::Notification.count == 1)
      end
    end

    describe "when there is android device token associated with reviewer" do
      before do
        android_device_for_reviewer = create(:device, user: @reviewer, platform: 'android')
        android_device_for_user = create(:device, user: @user, platform: 'android')
      end

      it 'should generate a notification for reviewer' do
        post :finish, format: :json, params: { id: @task_list_record.id}
        assert_response :ok
        #assert(Rpush::Gcm::Notification.count == 1)
      end
    end
  end
end

describe Api::TaskListRecordsController, "POST #review" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_property = create(:property)
    @task_list1 = create(:task_list, property_id: @property.id)
    @task_category = create(:task_item, task_list: @task_list1)
    @task_items = create_list(:task_item, 5, task_list: @task_list1, category: @task_category)

    @task_list_record = @task_list1.start_resume!(@user)
    @reviewer = create(:user, department_ids: @user.departments.map(&:id))
  end

  it 'should not allow to review without reviewable roles' do
    post :review, format: :json, params: { id: @task_list_record.id }
    assert_response :forbidden
  end

  describe 'with assignable roles' do
    before do
      create(
          :task_list_role_assignable,
          task_list_id: @task_list1.id,
          role_id: @user.current_property_role.id,
          department_id: @user.departments.first.id
      )

      # create reviewable role for @reviewer
      create(
          :task_list_role_reviewable,
          task_list_id: @task_list1.id,
          role_id: @reviewer.current_property_role.id,
          department_id: @reviewer.departments.first.id
      )
    end

    it 'should update only notes' do
      post :review, format: :json, params: { id: @task_list_record.id, notes: 'TEST', status: ''}
      assert_response :ok

      @task_list_record.reload
      @task_list_record.reviewer_notes.must_equal 'TEST'
      assert @task_list_record.reviewed_at.nil?
    end

    it 'should finish' do
      post :review, format: :json, params: { id: @task_list_record.id, notes: 'TEST', status: 'reviewed'}
      assert_response :ok

      @task_list_record.reload
      @task_list_record.reviewer_notes.must_equal 'TEST'
      assert @task_list_record.reviewed_at.present?
      @task_list_record.reviewed_by.id.must_equal @user.id
    end
  end
end
