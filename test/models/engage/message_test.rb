require "test_helper"

describe Engage::Message do
  let(:parent_feed_user) { create(:user) }
  let(:parent_feed) { create(:engage_message, created_by_id: parent_feed_user.id) }
  let(:feed) { create(:engage_message, parent_id: parent_feed.id) }
end
