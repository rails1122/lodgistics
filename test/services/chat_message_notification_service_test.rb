require "test_helper"

class ChatMessageNotificationServiceTest < ActiveSupport::TestCase
  let(:current_user) { create(:user) }
  let(:mentioned_user) { create(:user) }
  let(:chat_message) { create(:chat_message) }
  let(:mention) { create(:mention, mentionable: chat_message) }
  let(:service) { ChatMessageNotificationService.new(chat_message: chat_message, current_user: current_user) }

  before do
    mention
  end

  it do
    name = chat_message.sender.try(:name)
    msg = chat_message.try(:message)
    result = "#{name} replied to your message:\n#{msg}"
    assert(service.notification_body_for_parent_message_sender == result)
  end

  it do
    name = chat_message.sender.try(:name)
    mentioned_user_names_with_at_sign = chat_message.mentioned_users.map { |i| "@#{i.name}" }.join(" ")
    msg = chat_message.try(:message)
    result = "#{name} mentioned you:\n#{mentioned_user_names_with_at_sign} #{msg}"
    assert(service.notification_body_for_mentioned_user == result)
  end

  it do
    assert(service.notification_title_for_mentioned_user == "You were mentioned")
  end

  it do
    assert(service.notification_title_for_parent_message_sender == "New reply on your chat message")
  end
end
