require "test_helper"

class UnreadMentionNotificationServiceTest < ActiveSupport::TestCase
  let(:user) { create(:user) }
  let(:chat_user1) { create(:user, current_property_role: Role.gm) }
  let(:chat_user2) { create(:user, current_property_role: Role.gm) }
  let(:chat) { create(:chat, created_by: user, property: user.properties.first, users: [ chat_user1, user, chat_user2 ]) }
  let(:chat_msg) do
    create(:chat_message, chat_id: chat.id, sender: chat_user1, property: user.properties.first)
  end
  let(:feed_post) do
    create(:engage_message, property: user.properties.first)
  end
  let(:my_message_mention) { create(:mention, user_id: user.id, mentionable: chat_msg) }
  let(:my_feed_mention) { create(:mention, user_id: user.id, mentionable: feed_post) }
  let(:notification_service) { UnreadMentionNotificationService.new }
  let(:rpush_apns_app) { create(:rpush_apns_app) }

  describe "#execute" do
    before do
      rpush_apns_app
      create(:device, user: user)
    end

    describe "when user has unread mentions notifications pending" do
      before do
        my_message_mention
        my_feed_mention
      end

      it "sends unread mentions notification with count" do
        notification_service.execute(user.id)
        assert(Rpush::Apns::Notification.count == 1)
        assert_match(
          "You have been mentioned 2 times in #{user.properties.first.name}. "\
          "Check these posts and messages soon!",
          Rpush::Apns::Notification.last.alert["body"]
        )
      end

      describe 'when user has unread mention push notification disabled' do
        before do
          user.push_notification_setting.update(unread_mention_notification_enabled: false)
        end

        it do
          notification_service.execute(user.id)
          assert(Rpush::Apns::Notification.count == 0)
        end
      end
    end

    describe "when user has no unread mentions" do
      before do
        notification_service.execute(user.id)
      end

      it "doesn't send any notifications" do
        assert(Rpush::Apns::Notification.count == 0)
      end
    end
  end

end
