require "test_helper"

class UnreadMessageNotificationServiceTest < ActiveSupport::TestCase
  let(:user) { create(:user) }
  let(:chat_user1) { create(:user, current_property_role: Role.gm) }
  let(:chat_user2) { create(:user, current_property_role: Role.gm) }
  let(:group_chat) { create(:chat, created_by: user, property: user.properties.first, users: [ chat_user1, user, chat_user2 ]) }
  let(:private_chat) { create(:chat, created_by: user, property: user.properties.first, users: [ chat_user1, user ], is_private: true) }
  let(:notification_service) { UnreadMessageNotificationService.new }
  let(:rpush_apns_app) { create(:rpush_apns_app) }

  describe "#execute" do
    before do
      rpush_apns_app
      create(:device, user: user)
    end

    describe "when user has unread group message notifications pending" do
      before do
        create(:chat_message, chat_id: group_chat.id, sender: chat_user1,
                              property: user.properties.first)
      end

      it "sends unread group notification with count" do
        notification_service.execute(user)
        assert(Rpush::Apns::Notification.count == 1)
        assert_match(
          "You have 1 unread message in 1 group at "\
          "#{user.properties.first.name}. Check them soon!",
          Rpush::Apns::Notification.last.alert["body"]
        )
      end

      describe 'when user has unread message push notification disabled' do
        before do
          user.push_notification_setting.update(unread_message_notification_enabled: false)
        end

        it 'should not create push notification' do
          notification_service.execute(user)
          assert(Rpush::Apns::Notification.count == 0)
        end
      end
    end

    describe "when user has unread private message notifications pending" do
      before do
        create(:chat_message, chat_id: private_chat.id, sender: chat_user1,
                              property: user.properties.first)
        notification_service.execute(user)
      end

      it "sends unread group notification with count" do
        assert(Rpush::Apns::Notification.count == 1)
        assert_match(
          "You have 1 unread direct message from 1 of your colleague at "\
          "#{user.properties.first.name}.Check them soon!",
          Rpush::Apns::Notification.last.alert["body"]
        )
      end
    end

    describe "when user has no unread messages" do
      before do
        notification_service.execute(chat_user1)
      end

      it "doesn't send any notifications" do
        assert(Rpush::Apns::Notification.count == 0)
      end
    end
  end

end
