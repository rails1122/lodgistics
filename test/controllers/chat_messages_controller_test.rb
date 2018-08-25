require 'test_helper'

describe ChatMessagesController, "POST #create" do
  include Devise::Test::ControllerHelpers

  let(:user){ create(:user, current_property_role: Role.agm) }
  let(:current_property) { user.current_property }

  let(:user1) { create(:user, current_property_role: Role.gm) }
  let(:user2) { create(:user, current_property_role: Role.gm) }

  let(:chat_i_am_in) { create(:chat, user_ids: [ user.id, user1.id, user2.id ], property_id: current_property.id) }

  let(:chat_message_fields) {
    [
        'id', 'message', 'sender_id', 'chat_id', 'mentioned_user_ids', 'reads_count', 'read', 'updated_at',
        'created_at', 'image_url', 'responding_to_chat_message_id', 'read_by_user_ids', 'sender_avatar_img_url',
        'mention_ids', 'work_order_id', 'work_order_url', 'work_order', 'room_number', 'room_id'
    ].sort
  }

  before do
    chat_i_am_in
    sign_in user
  end

  it do
    post :create, params: { chat_message: { message: 'hello world', chat_id: chat_i_am_in.id } }, format: :json
    assert(ChatMessage.count == 1)
    assert_response 200
    json = JSON.parse(response.body)
    assert(json.keys.sort == chat_message_fields)
  end
end

