require "test_helper"

class FeedNotificationServiceTest < ActiveSupport::TestCase
  let(:current_user) { create(:user) }
  let(:mentioned_user) { create(:user) }
  let(:feed) { create(:engage_message) }
  let(:mention) { create(:mention, mentionable: feed) }
  let(:service) { FeedNotificationService.new(feed: feed, current_user: current_user) }

  before do
    mention
  end

  it do
    name = feed.created_by.try(:name)
    result = "#{name} commented on your log post:\n#{feed.body}"
    assert(service.notification_msg_for_parent_feed == result)
  end

  it do
    mentioned_user_names_with_at_sign = feed.mentioned_users.map { |i| "@#{i.name}" }.join(" ")
    name = feed.created_by.try(:name)
    result = "#{name} mentioned you:\n#{feed.body}"
    assert(service.notification_msg_for_mentioned_user == result)
  end

  it do
    assert(service.notification_title_for_mentioned_user == "You were mentioned")
  end

  it do
    assert(service.notification_title_for_parent_feed == "New comment on your post")
  end
end
