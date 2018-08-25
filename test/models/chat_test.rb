require "test_helper"

describe Chat do
  let(:property) { create(:property) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:chat_with_no_user)  { create(:chat, property: property) }
  let(:chat_with_one_user) { create(:chat, property: property, users: [ user1 ]) }
  let(:chat_with_two_user) { create(:chat, property: property, users: [ user1, user2 ]) }
  let(:private_chat) { create(:chat, property: property, users: [ user2 ], is_private: true, user: user1, created_by: user1) }
  let(:group_chat_name) { "TEST_GROUP_CHAT" }
  let(:group_chat) { create(:chat, property: property, users: [ user2 ], is_private: false, user: user1, created_by: user1, name: group_chat_name) }

  it 'it is okay to create chat room with no user' do
    #assert_raises(ActiveRecord::RecordInvalid) { chat_with_no_user }
    #assert_raises(ActiveRecord::RecordInvalid) { chat_with_one_user }
    assert(chat_with_no_user.valid?)
    assert(chat_with_one_user.valid?)
    assert(chat_with_two_user.valid?)
  end

  it 'notification msg on private chat' do
    assert(private_chat.notification_msg == "#{user1.name} started a private conversation with you.")
  end

  it 'notification msg on group chat' do
    assert(group_chat.notification_msg == "#{user1.name} added you to the group 'TEST_GROUP_CHAT'")
  end
end
