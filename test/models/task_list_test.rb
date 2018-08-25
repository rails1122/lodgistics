require 'test_helper'

describe TaskList do
  let(:property) { create(:property) }
  let(:department1) { create(:department) }
  let(:department2) { create(:department) }
  let(:user1) { create(:user, department_ids: [department1.id], current_property_role: Role.gm) }
  let(:user2) { create(:user, department_ids: [department2.id], current_property_role: Role.agm) }
  let(:user3) { create(:user, department_ids: [department1.id, department2.id], current_property_role: Role.manager) }

  before :each do
    property.switch!

    user1.touch
    user2.touch
    user3.touch
  end

  describe '#assignable users' do
    let(:task_list) { create(:task_list) }

    it 'should work for single roles' do
      create(:task_list_role_assignable, department: department1, role: Role.gm, task_list: task_list)

      task_list.assignable_users.map(&:id).must_equal [user1.id]
    end

    it 'should work for multiple roles' do
      create(:task_list_role_assignable, department: department1, role: Role.gm, task_list: task_list)
      create(:task_list_role_assignable, department: department1, role: Role.manager, task_list: task_list)

      task_list.assignable_users.map(&:id).sort.must_equal [user1, user3].map(&:id).sort
    end

    it 'should work for multiple departments' do
      create(:task_list_role_assignable, department: department1, role: Role.gm, task_list: task_list)
      create(:task_list_role_assignable, department: department2, role: Role.agm, task_list: task_list)
      create(:task_list_role_assignable, department: department1, role: Role.manager, task_list: task_list)
      create(:task_list_role_assignable, department: department2, role: Role.manager, task_list: task_list)

      task_list.assignable_users.map(&:id).sort.must_equal [user1, user2, user3].map(&:id).sort
    end
  end

  describe '#reviewable users' do
    let(:task_list) { create(:task_list) }

    it 'should work for single roles' do
      create(:task_list_role_reviewable, department: department1, role: Role.gm, task_list: task_list)

      task_list.reviewable_users.map(&:id).sort.must_equal [user1.id]
    end

    it 'should work for multiple roles' do
      create(:task_list_role_reviewable, department: department1, role: Role.gm, task_list: task_list)
      create(:task_list_role_reviewable, department: department1, role: Role.manager, task_list: task_list)

      task_list.reviewable_users.map(&:id).sort.must_equal [user1, user3].map(&:id).sort
    end

    it 'should work for multiple departments' do
      create(:task_list_role_reviewable, department: department1, role: Role.gm, task_list: task_list)
      create(:task_list_role_reviewable, department: department2, role: Role.agm, task_list: task_list)
      create(:task_list_role_reviewable, department: department1, role: Role.manager, task_list: task_list)
      create(:task_list_role_reviewable, department: department2, role: Role.manager, task_list: task_list)

      task_list.reviewable_users.map(&:id).sort.must_equal [user1, user2, user3].map(&:id).sort
    end
  end
end