require 'test_helper'

task_list_fields = %w(id property_id name description notes started_at updated_at task_list_record_id).sort
task_list_record_fields = %w(user id started_at status notes created_at updated_at categories task_list finished_by finished_at reviewer_notes review_notified_at reviewed_at reviewed_by permission_to formatted_finished_at formatted_reviewed_at).sort
activity_fields = %w(id finished_at status task_list finished_by reviewer_notes permission_to reviewed_by reviewed_at formatted_finished_at incomplete_count total_count day_finished_at formatted_reviewed_at).sort

describe Api::TaskListsController, "GET #index" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_property = FactoryGirl.create(:property)
    @task_list_not_in_property = FactoryGirl.create(:task_list, property_id: @another_property.id)
    @task_list_in_property = FactoryGirl.create(:task_list, property_id: @property.id)
    @another_task_list_in_property = FactoryGirl.create(:task_list, property_id: @property.id)
    @inactive_task_list_in_property = FactoryGirl.create(:task_list, property_id: @property.id, inactivated_by_id: @user.id)
  end

  describe 'with no assign permission' do
    it do
      get :index, format: :json
      json = api_response
      ids = json.map { |i| i['id'] }
      refute_includes(ids, @task_list_in_property.id)
      refute_includes(ids, @another_task_list_in_property.id)
      refute_includes(ids, @task_list_not_in_property.id)
      refute_includes(ids, @inactive_task_list_in_property.id)
    end
  end

  describe 'with assign permission' do
    before do
      create(
        :task_list_role_assignable,
        task_list_id: @task_list_in_property.id,
        role_id: @user.current_property_role.id,
        department_id: @user.departments.first.id
      )
    end

    it do
      get :index, format: :json
      json = api_response
      ids = json.map { |i| i['id'] }
      assert_includes(ids, @task_list_in_property.id)
      refute_includes(ids, @another_task_list_in_property.id)
      refute_includes(ids, @task_list_not_in_property.id)
      refute_includes(ids, @inactive_task_list_in_property.id)
    end

    it do
      get :index, format: :json
      json = api_response
      assert(json.first.keys.sort == task_list_fields)
    end
  end
end

describe Api::TaskListsController, "GET #activities" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_property = FactoryGirl.create(:property)
    @task_list_not_in_property = FactoryGirl.create(:task_list, property_id: @another_property.id)
    @task_list_in_property = FactoryGirl.create(:task_list, property_id: @property.id)
    @another_task_list_in_property = FactoryGirl.create(:task_list, property_id: @property.id)
  end

  describe 'with no assign permission' do
    it do
      get :activities, format: :json
      json = api_response
      assert(json.empty?)
    end
  end

  describe 'with assign permission' do
    before do
      create(
        :task_list_role_assignable,
        task_list_id: @task_list_in_property.id,
        role_id: @user.current_property_role.id,
        department_id: @user.departments.first.id
      )
    end

    describe 'when there is a started task_list_record' do
      before do
        @task_list_in_property.start_resume!(@user)
        assert(@task_list_in_property.started_task_list_record(@user) == TaskListRecord.last)
      end

      it do
        get :activities, format: :json
        json = api_response
        assert(json.empty?)
      end
    end

    describe 'when there is a task_list_record with status other than started' do
      before do
        @task_list_in_property.start_resume!(@user)
        @task_list_record = @task_list_in_property.started_task_list_record(@user)
        @task_list_record.finish!(@user)
      end

      it 'should return' do
        get :activities, format: :json
        json = api_response
        assert(json.first.keys.sort == activity_fields.sort)
        i = json.first
        assert(i['task_list']['id'] == @task_list_record.task_list.id)
      end

      it 'should return finished and incompleted list records' do
        @task_list1 = create(:task_list, property_id: @property.id)
        @task_category = create(:task_item, task_list: @task_list1)
        @task_items = create_list(:task_item, 5, task_list: @task_list1, category: @task_category)

        create(
            :task_list_role_assignable,
            task_list_id: @task_list1.id,
            role_id: @user.current_property_role.id,
            department_id: @user.departments.first.id
        )

        @task_list_record = @task_list1.start_resume!(@user)
        @task_item_record = @task_list_record.task_item_records.last

        @task_item_record.complete!(@user, {status: 'completed'})
        @task_list_record.finish!(@user)

        assert !@task_list_record.all_completed?

        get :activities, format: :json
        api_response.length.must_equal 2
        api_response[0]['permission_to'].must_equal 'assign'
      end
    end
  end

  describe 'with review permission' do
    before do
      create(
        :task_list_role_reviewable,
        task_list_id: @task_list_in_property.id,
        role_id: @user.current_property_role.id,
        department_id: @user.departments.first.id
      )
    end

    describe 'when there is a task_list_record with status other than started' do
      before do
        @task_list_in_property.start_resume!(@user)
        @task_list_record = @task_list_in_property.started_task_list_record(@user)
        @task_list_record.update(status: 'finished', finished_at: DateTime.now, finished_by: @user)
      end

      it do
        get :activities, format: :json
        json = api_response
        assert(json.first.keys.sort == activity_fields.sort)
        i = json.first
        assert(i['task_list']['id'] == @task_list_record.task_list.id)
        i['permission_to'].must_equal 'review'
      end
    end
  end
end

describe Api::TaskListsController, "GET #show" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_property = FactoryGirl.create(:property)
    @task_list_not_in_property = FactoryGirl.create(:task_list, property_id: @another_property.id)
    @task_list_in_property = FactoryGirl.create(:task_list, property_id: @property.id)
  end

  it 'should not able to see without permission' do
    get :show, format: :json, params: { id: @task_list_in_property.id }
    assert_response :forbidden
  end

  describe 'with assign permission' do
    before do
      create(
          :task_list_role_assignable,
          task_list_id: @task_list_in_property.id,
          role_id: @user.current_property_role.id,
          department_id: @user.departments.first.id
      )
    end

    it 'should render task list' do
      get :show, format: :json, params: { id: @task_list_in_property.id }
      assert_response :ok
      api_response.keys.sort.must_equal task_list_fields
    end

    it 'for not started task_list' do
      get :show, format: :json, params: { id: @task_list_in_property.id }
      assert_response :ok
      json = api_response
      assert(json['id'] == @task_list_in_property.id)
      assert(json['property_id'] == @task_list_in_property.property_id)
      assert(json['name'] == @task_list_in_property.name)
      assert(json['description'] == @task_list_in_property.description)
      assert(json['notes'] == @task_list_in_property.notes)
      assert(json['task_list_record_id'] == nil)
      assert(json['started_at'] == nil)
      assert(json['updated_at'] == nil)
    end

    it 'for started task_list' do
      @task_list_in_property.start_resume!(@user)
      get :show, format: :json, params: { id: @task_list_in_property.id }
      assert_response :ok
      json = api_response
      assert(json['id'] == @task_list_in_property.id)
      assert(json['property_id'] == @task_list_in_property.property_id)
      assert(json['name'] == @task_list_in_property.name)
      assert(json['description'] == @task_list_in_property.description)
      assert(json['notes'] == @task_list_in_property.notes)
      assert(json['task_list_record_id'] == @task_list_in_property.task_list_records.where(user_id: @user.id, status: 'started').first.try(:id))
      assert(DateTime.parse(json['started_at']).to_i == @task_list_in_property.task_list_records.where(user_id: @user.id, status: 'started').first.try(:started_at).to_i)
      assert(DateTime.parse(json['updated_at']).to_i == @task_list_in_property.task_list_records.where(user_id: @user.id, status: 'started').first.try(:updated_at).to_i)
    end
  end

  it do
    get :show, format: :json, params: { id: @task_list_not_in_property.id }
    assert_response :no_content
  end
end

describe Api::TaskListsController, "POST #start_resume" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_property = create(:property)
    @task_list1 = create(:task_list, property_id: @property.id)
    @task_category = create(:task_item, task_list: @task_list1)
    @task_items = create_list(:task_item, 5, task_list: @task_list1, category: @task_category)
    @task_list2 = create(:task_list, property_id: @another_property.id)
  end

  it 'should not allow to start without assignable roles' do
    post :start_resume, format: :json, params: { id: @task_list1.id }
    assert_response :forbidden
  end

  it 'should not start another property task list' do
    post :start_resume, format: :json, params: { id: @task_list2.id }
    assert_response :no_content
  end

  describe 'with assignable roles' do
    before do
      create(
          :task_list_role_assignable,
          task_list_id: @task_list1.id,
          role_id: @user.current_property_role.id,
          department_id: @user.departments.first.id
      )
    end

    it 'should start task list' do
      post :start_resume, format: :json, params: { id: @task_list1.id, task_list_record: {notes: 'Test Notes'} }
      assert_response :ok

      api_response.keys.sort.must_equal task_list_record_fields
    end

    it 'should generate all task item records' do
      post :start_resume, format: :json, params: { id: @task_list1.id, task_list_record: {notes: 'Test Notes'} }
      assert_response :ok

      TaskListRecord.last.task_item_records.count.must_equal @task_list1.task_items.count
    end
  end
end
