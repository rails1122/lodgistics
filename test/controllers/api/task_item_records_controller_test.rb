require 'test_helper'

describe Api::TaskItemRecordsController, "POST #complete" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_property = create(:property)
    @task_list1 = create(:task_list, property_id: @property.id)
    @task_category = create(:task_item, task_list: @task_list1)
    @task_items = create_list(:task_item, 5, task_list: @task_list1, category: @task_category)

    @task_list_record = @task_list1.start_resume!(@user)
    @task_item_record = @task_list_record.task_item_records.last
  end

  it 'should not allow to complete without assignable roles' do
    post :complete, format: :json, params: { id: @task_item_record.id }
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
    end

    it 'should finish task list record with incomplete status' do
      post :complete, format: :json, params: {id: @task_item_record.id, task_item_record: {comment: 'TEST COMMENT', status: 'completed'}}
      assert_response :ok

      @task_item_record.reload
      assert @task_item_record.completed_at.present?
      @task_item_record.comment.must_equal 'TEST COMMENT'
    end

    it 'should update only comment without complete item' do
      post :complete, format: :json, params: {id: @task_item_record.id, task_item_record: {comment: 'TEST COMMENT'}}
      assert_response :ok

      @task_item_record.reload
      assert !@task_item_record.completed_at.present?
      @task_item_record.comment.must_equal 'TEST COMMENT'
    end
  end
end

describe Api::TaskItemRecordsController, "POST #reset" do
  before do
    create_user_for_property
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @another_property = create(:property)
    @task_list1 = create(:task_list, property_id: @property.id)
    @task_category = create(:task_item, task_list: @task_list1)
    @task_items = create_list(:task_item, 5, task_list: @task_list1, category: @task_category)

    @task_list_record = @task_list1.start_resume!(@user)
    @task_item_record = @task_list_record.task_item_records.last
  end

  it 'should not allow to complete without assignable roles' do
    post :reset, format: :json, params: { id: @task_item_record.id }
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

      @task_item_record.complete!(@user, {task_item_record: {comment: 'TEST COMMENT', status: 'completed'}})
    end

    it 'should finish task list record with incomplete status' do
      post :reset, format: :json, params: {id: @task_item_record.id}
      assert_response :ok

      @task_item_record.reload
      assert @task_item_record.completed_at.nil?
    end
  end
end