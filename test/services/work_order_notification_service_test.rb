require "test_helper"

class WorkOrderNotificationServiceTest < ActiveSupport::TestCase
  let(:assignee) { create(:user) }
  let(:creator) { create(:user) }
  let(:work_order) { build(:maintenance_work_order, assigned_to: assignee, created_by: creator, opened_by: creator) }
  let(:high_priority_work_order) { build(:maintenance_work_order, assigned_to: assignee, created_by: creator, opened_by: creator, priority: 'h') }

  describe "#execute_assigned" do
    before do
      create(:rpush_apns_app)
      create(:device, user: assignee)
    end

    it "should send a push notification to the assigned user" do
      work_order.save(validate: false)
      WorkOrderNotificationService.new(work_order.id).execute_assigned
      work_order.reload

      assert_match(
        "WO #{work_order.id} assigned to you in #{work_order.property.name}",
        Rpush::Apns::Notification.last.alert["title"]
      )
      assert_match(
        "[Medium] for #{work_order.location_name}\n#{work_order.description}",
        Rpush::Apns::Notification.last.alert["body"]
      )
    end

    it do
      high_priority_work_order.save(validate: false)
      WorkOrderNotificationService.new(high_priority_work_order.id).execute_assigned
      high_priority_work_order.reload

      assert_match(
        "[High Priority] WO #{high_priority_work_order.id} assigned to you in #{high_priority_work_order.property.name}",
        Rpush::Apns::Notification.last.alert["title"]
      )
      assert_match(
        "[High] for #{high_priority_work_order.location_name}\n#{high_priority_work_order.description}",
        Rpush::Apns::Notification.last.alert["body"]
      )
    end

    describe 'assigned user has work_order_assigned_notification disabled' do
      before do
        assignee.push_notification_setting.update(work_order_assigned_notification_enabled: false)
      end

      it 'should not create push notification' do
        work_order.save(validate: false)
        WorkOrderNotificationService.new(work_order.id).execute_assigned
        assert(Rpush::Apns::Notification.count == 0)
      end
    end
  end

  describe "#execute_complete" do
    before do
      create(:rpush_apns_app)
      create(:device, user: creator)
      work_order.save(validate: false)
    end

    it "should send a push notification to the creator of the work order when closed" do
      work_order.update(closed_by: creator, closed_at: DateTime.now)
      WorkOrderNotificationService.new(work_order.id).execute_complete
      work_order.reload

      assert_match(
        "WO ##{work_order.id} closed!",
        Rpush::Apns::Notification.last.alert["title"]
      )
      assert_match(
        "#{work_order.closed_by&.name} has completed work order for #{work_order.location_name} at #{work_order.closed_at&.strftime("%H:%M")}",
        Rpush::Apns::Notification.last.alert["body"]
      )
    end

    describe 'creator user has work_order_assigned_notification disabled' do
      before do
        creator.push_notification_setting.update(work_order_assigned_notification_enabled: false)
      end

      it 'should not create push notification' do
        work_order.save(validate: false)
        WorkOrderNotificationService.new(work_order.id).execute_complete
        assert(Rpush::Apns::Notification.count == 0)
      end
    end
  end
end
