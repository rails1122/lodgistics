require 'test_helper'

describe Api::ChatMentionsController do
  let(:chat_user1) { create(:user, current_property_role: Role.gm) }
  let(:chat_user2) { create(:user, current_property_role: Role.gm) }
  let(:chat) { create(:chat, created_by: @user, property_id: @property.id, users: [ chat_user1, @user, chat_user2 ]) }
  let(:chat_msg_with_mention_at_me) do
    m = create(:chat_message, chat: chat, sender: chat_user1, property: @property)
    m.mentions << create(:mention, user_id: @api_key.user_id)
    m
  end
  let(:chat_mentions_at_me) { chat_msg_with_mention_at_me.mentions }

  let(:chat_msg_with_mention_at_other) do
    m = create(:chat_message, chat: chat, sender: chat_user1, property: @property)
    m.mentions << create(:mention, user_id: chat_user2.id)
    m
  end
  let(:chat_mentions_at_other) { chat_msg_with_mention_at_other.mentions }

  before 'set headers' do
    create_user_for_property
    @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
    chat_msg_with_mention_at_me
    chat_msg_with_mention_at_other
  end

  it 'cannot update chat mention at other person' do
    mention_at_other = chat_mentions_at_other.first
    put :update, format: :json, params: {
      id: mention_at_other.id, chat_mention: { status: 'checked' }
    }
    assert_response :unauthorized
  end

  it 'can update my chat mention' do
    mention_at_me = chat_mentions_at_me.first
    put :update, format: :json, params: {
      id: mention_at_me.id, chat_mention: { status: 'checked' }
    }
    assert_response 200

    json = JSON.parse(response.body)
    json['id'].must_equal mention_at_me.id
    json['status'].must_equal 'checked'

    mention_at_me.reload.status.must_equal 'checked'
  end

  it 'cannot update with invalid status' do
    mention_at_me = chat_mentions_at_me.first
    put :update, format: :json, params: {
      id: mention_at_me.id, chat_mention: { status: 'invalid_status' }
    }
    assert_response 422
    json = JSON.parse(response.body)
    json['error'].must_equal "'invalid_status' is not a valid status"
  end

end
