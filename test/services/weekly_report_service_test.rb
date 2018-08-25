require "test_helper"

class WeeklyReportServiceTest < ActiveSupport::TestCase
  let(:property){ create(:property) }
  let(:weekly_report_data){ WeeklyReport.new(property).get_data }
  let(:today){ Date.today }
  let(:date_1_week_ago){ today - 1.week }
  let(:date_2_week_ago){ today - 2.week }

  before do
    property.switch!
  end

  describe '#get_data' do

    it 'should display correct dates and property name' do
      data = weekly_report_data
      assert data[:current].present?
      assert data[:previous].present?
      assert data[:current][:date].present?
      assert data[:previous][:date].present?
      assert_equal Date.today.beginning_of_week, data[:current][:date]
      assert_equal (Date.today.beginning_of_week - 7.day), data[:previous][:date]
      assert data[:name].present?
      assert_equal property.name, data[:name]
    end

    describe 'when no data yet' do
      it 'should include all values in zero' do
        data = weekly_report_data
        assert data[:current][:work_orders].present?
        assert data[:previous][:work_orders].present?
        assert data[:current][:checklists].present?
        assert data[:previous][:checklists].present?
        assert data[:current][:guest_logs].present?
        assert data[:previous][:guest_logs].present?
        assert data[:current][:chats].present?
        assert data[:previous][:chats].present?
        assert_equal 0, data[:current][:work_orders][:new]
        assert_equal 0, data[:current][:work_orders][:opened]
        assert_equal 0, data[:current][:work_orders][:closed]
        assert_equal 0, data[:previous][:work_orders][:new]
        assert_equal 0, data[:previous][:work_orders][:opened]
        assert_equal 0, data[:previous][:work_orders][:closed]
        assert_equal 0, data[:current][:checklists][:completed]
        assert_equal 0, data[:current][:checklists][:reviewed]
        assert_equal 0, data[:previous][:checklists][:completed]
        assert_equal 0, data[:previous][:checklists][:reviewed]
        assert_equal 0, data[:current][:guest_logs]
        assert_equal 0, data[:previous][:guest_logs]
        assert_equal 0, data[:current][:chats]
        assert_equal 0, data[:previous][:chats]
      end
    end

    describe 'when WOs have been created in current week' do
      let(:wo_opened){ FactoryGirl.create(:work_order, property: property,
                                   status: Maintenance::WorkOrder::STATUS_OPEN) }
      let(:wo_closed){ FactoryGirl.create(:work_order, property: property,
                                   status: Maintenance::WorkOrder::STATUS_CLOSED) }

      before do
        wo_opened
        wo_closed
      end

      it 'should get correct WO counters' do
        data = weekly_report_data
        assert_equal 0, data[:current][:work_orders][:new]
        assert_equal 1, data[:current][:work_orders][:opened]
        assert_equal 0, data[:current][:work_orders][:closed]
        assert_equal 0, data[:previous][:work_orders][:new]
        assert_equal 1, data[:previous][:work_orders][:opened]
        assert_equal 0, data[:previous][:work_orders][:closed]
      end
    end

    describe 'when WOs have been created in previous week' do
      let(:wo_opened){ FactoryGirl.create(:work_order, property: property,
                                   status: Maintenance::WorkOrder::STATUS_OPEN, created_at: date_1_week_ago, opened_at: date_1_week_ago) }
      let(:wo_closed){ FactoryGirl.create(:work_order, property: property,
                                   status: Maintenance::WorkOrder::STATUS_CLOSED, created_at: date_1_week_ago, closed_at: date_1_week_ago) }

      before do
        wo_opened
        wo_closed
      end

      it 'should get correct WO counters' do
        data = weekly_report_data
        assert_equal 2, data[:current][:work_orders][:new]
        assert_equal 1, data[:current][:work_orders][:opened]
        assert_equal 1, data[:current][:work_orders][:closed]
        assert_equal 0, data[:previous][:work_orders][:new]
        #assert_equal 1, data[:previous][:work_orders][:opened]
        assert_equal 0, data[:previous][:work_orders][:closed]
      end
    end

    describe 'when WOs have been created in previous week before that' do
      let(:wo_opened){ FactoryGirl.create(:work_order, property: property,
                                   status: Maintenance::WorkOrder::STATUS_OPEN, created_at: date_2_week_ago, opened_at: date_2_week_ago) }
      let(:wo_closed){ FactoryGirl.create(:work_order, property: property,
                                   status: Maintenance::WorkOrder::STATUS_CLOSED, created_at: date_2_week_ago, closed_at: date_2_week_ago) }

      before do
        wo_opened
        wo_closed
      end

      it 'should get correct WO counters' do
        data = weekly_report_data
        assert_equal 0, data[:current][:work_orders][:new]
        assert_equal 1, data[:current][:work_orders][:opened]
        assert_equal 0, data[:current][:work_orders][:closed]
        assert_equal 2, data[:previous][:work_orders][:new]
        #assert_equal 1, data[:previous][:work_orders][:opened]
        assert_equal 1, data[:previous][:work_orders][:closed]
      end
    end


    describe 'when Checklists have been created in current week' do
      let(:checklist_completed){ FactoryGirl.create(:task_list_record, status: :finished) }
      let(:checklist_reviewed ){ FactoryGirl.create(:task_list_record, status: :reviewed) }
      let(:checklist_started  ){ FactoryGirl.create(:task_list_record, ) }

      before do
        checklist_started
        checklist_reviewed
        checklist_completed
      end

      it 'should get correct Checklists counters' do
        data = weekly_report_data
        assert_equal 0, data[:current][:checklists][:completed]
        assert_equal 0, data[:current][:checklists][:reviewed]
        assert_equal 0, data[:previous][:checklists][:completed]
        assert_equal 0, data[:previous][:checklists][:reviewed]
      end
    end

    describe 'when Checklists have been created in previous week' do
      let(:checklist_completed){ FactoryGirl.create(:task_list_record, status: :finished, created_at: date_1_week_ago) }
      let(:checklist_reviewed ){ FactoryGirl.create(:task_list_record, status: :reviewed, created_at: date_1_week_ago) }
      let(:checklist_started  ){ FactoryGirl.create(:task_list_record, created_at: date_1_week_ago) }

      before do
        checklist_started
        checklist_reviewed
        checklist_completed
      end

      it 'should get correct Checklists counters' do
        data = weekly_report_data
        assert_equal 1, data[:current][:checklists][:completed]
        assert_equal 1, data[:current][:checklists][:reviewed]
        assert_equal 0, data[:previous][:checklists][:completed]
        assert_equal 0, data[:previous][:checklists][:reviewed]
      end
    end

    describe 'when Checklists have been created in previous week before that' do
      let(:checklist_completed){ FactoryGirl.create(:task_list_record, status: :finished, created_at: date_2_week_ago) }
      let(:checklist_reviewed ){ FactoryGirl.create(:task_list_record, status: :reviewed, created_at: date_2_week_ago) }
      let(:checklist_started  ){ FactoryGirl.create(:task_list_record, created_at: date_2_week_ago) }

      before do
        checklist_started
        checklist_reviewed
        checklist_completed
      end

      it 'should get correct Checklists counters' do
        data = weekly_report_data
        assert_equal 0, data[:current][:checklists][:completed]
        assert_equal 0, data[:current][:checklists][:reviewed]
        assert_equal 1, data[:previous][:checklists][:completed]
        assert_equal 1, data[:previous][:checklists][:reviewed]
      end
    end


    describe 'when Guest Logs have been created in current week' do
      let(:guest_log) { FactoryGirl.create(:engage_message, property: property) }

      before do
        guest_log
      end

      it 'should get correct Guest Log counters' do
        data = weekly_report_data
        assert_equal 0, data[:current][:guest_logs]
        assert_equal 0, data[:previous][:guest_logs]
      end
    end

    describe 'when Guest Logs have been created in previous week' do
      let(:guest_log) { FactoryGirl.create(:engage_message, property: property, created_at: date_1_week_ago) }

      before do
        guest_log
      end

      it 'should get correct Guest Log counters' do
        data = weekly_report_data
        assert_equal 1, data[:current][:guest_logs]
        assert_equal 0, data[:previous][:guest_logs]
      end
    end

    describe 'when Guest Logs have been created in previous week before that' do
      let(:guest_log) { FactoryGirl.create(:engage_message, property: property, created_at: date_2_week_ago) }

      before do
        guest_log
      end

      it 'should get correct Guest Log counters' do
        data = weekly_report_data
        assert_equal 0, data[:current][:guest_logs]
        assert_equal 1, data[:previous][:guest_logs]
      end
    end


    describe 'when Chats have been created in current week' do
      let(:chat_message) { FactoryGirl.create(:chat_message, property: property) }

      before do
        chat_message
      end

      it 'should get correct Chat counter' do
        data = weekly_report_data
        assert_equal 0, data[:current][:chats]
        assert_equal 0, data[:previous][:chats]
      end
    end

    describe 'when Chats have been created in previous week' do
      let(:chat_message) { FactoryGirl.create(:chat_message, property: property, created_at: date_1_week_ago) }

      before do
        chat_message
      end

      it 'should get correct Chat counter' do
        data = weekly_report_data
        assert_equal 1, data[:current][:chats]
        assert_equal 0, data[:previous][:chats]
      end
    end

    describe 'when Chats have been created in previous week before that' do
      let(:chat_message) { FactoryGirl.create(:chat_message, property: property, created_at: date_2_week_ago) }

      before do
        chat_message
      end

      it 'should get correct Chat counter' do
        data = weekly_report_data
        assert_equal 0, data[:current][:chats]
        assert_equal 1, data[:previous][:chats]
      end
    end

  end #! #get_data
end
