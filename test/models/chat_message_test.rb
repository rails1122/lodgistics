require "test_helper"

class ChatMessageTest < ActiveSupport::TestCase
  let(:me) { create(:user) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }
  let(:property) { me.properties.first }
  let(:chat_i_am_in) { create(:chat, user_ids: [ me.id, user1.id, user2.id ], property: property) }
  let(:chat_i_am_not_in) { create(:chat, user_ids: [ user1.id, user2.id ], property: property) }

  let(:valid_chat_msg) { create(:chat_message, sender_id: me.id, message: 'hello world', chat: chat_i_am_in) }
  let(:invalid_chat_msg) { create(:chat_message, sender_id: me.id, message: 'hello world', chat: chat_i_am_not_in) }

  it do
    assert(valid_chat_msg.valid?)
  end

  it do
    assert_raises(ActiveRecord::RecordInvalid) { invalid_chat_msg }
  end

  it do
    assert(valid_chat_msg.can_be_read_by?(me))
    assert(valid_chat_msg.can_be_read_by?(user1))
    assert(valid_chat_msg.can_be_read_by?(user2))
    assert(valid_chat_msg.can_be_read_by?(user3) == false)
  end

  it do
    assert_raises(Errors::NotAuthorized) { valid_chat_msg.check_if_user_can_read(user3) }
  end
end
