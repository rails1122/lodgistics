require "test_helper"

describe Maintenance::WorkOrder do
  let(:work_order) { FactoryGirl.create(:work_order) }

  it do
    assert(work_order.closed_at == nil)
    assert(work_order.closed? == false)
  end

  it do
    work_order.close_by(work_order.opened_by, should_send_notification: false)
    assert(work_order.closed_at != nil)
    assert(work_order.closed? == true)
  end
end
