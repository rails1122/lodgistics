require "test_helper"

class ChatNotificationServiceTest < ActiveSupport::TestCase
  let(:user) { create(:user) }
  let(:chat_user1) { create(:user, current_property_role: Role.gm) }
  let(:chat) { create(:chat, created_by: user, property: user.properties.first, users: [ chat_user1, user ]) }
  let(:rpush_apns_app) { create(:rpush_apns_app) }

  describe "#send_notifications" do
    before do
      rpush_apns_app
      create(:device, user: chat_user1)
      ChatNotificationService.new(chat: chat, current_user: user).send_notifications
    end

    it "generates a creation notification to the users of the chat" do
      assert(Rpush::Notification.count == 1)
      assert_match("You were added to a chat", Rpush::Notification.last.alert["title"])
      assert_match(
        "#{chat.user.name} added you to to a chat #{chat.name}",
        Rpush::Notification.last.alert["body"]
      )
    end
  end
end
