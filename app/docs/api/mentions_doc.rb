module Api::MentionsDoc
  extend BaseDoc

  namespace 'api'
  resource :mentions

  doc_for :index do
    api :GET, '/mentions', 'Get mentions at current user'
    description <<-EOS
      If successful, it returns a json containing <tt>a list of mention object</tt>, sorted by created_at, with status <tt>200</tt>.

      Mention object contains:
        mention_id: Mention record id
        status: status (e.g. 'checked' 'not_checked')
        user_id: user id this mention targets at. should be same as current user
        created_at: created datetime
        updated_at: updated datetime
        mention_type: type of mention - 'feed_mention', 'chat_mention'
        mentioned_user_ids: a list of user ids that content mentions at
        acknowledged_by_me: true if chat message or feed was acknowledged by current user
        snoozed_at: snoozed at datetime
        snoozed: true if notification for this mention is snoozed
        content:
          content_id: id of content. (e.g. chat_message id, feed id)
          content_data: data of content (e.g. chat message content, feed content)
          content_type: type of content (e.g. group_chat, private_chat)
          content_type_id: id of content type (e.g. id of chat)
          content_type_name: name of content type (e.g. name of group chat)
          content_image: url in contnet. '' if none exists
          room_number: room number
          room_id: room id
          created_by:
            id: user id who created content (e.g. who created chat_message)
            name: user name
            avatar: user avatar
            role: user role
    EOS
   end

  doc_for :update do
    api :PUT, '/mentions/:id', 'Update mention'
    description <<-EOS
      If successful, it returns status <tt>200</tt> with json with <tt>mention object</tt>.
      If wrong parameter is given, it returns status <tt>422</tt>
      If trying to update another user's, it returns status <tt>401</tt>

      Mention object contains:
        id: mention Id
        status: status of mention (e.g. 'not_checked', 'checked)
        snoozed: snoozed status - true / false
        updated_at: updated_at
    EOS
    param :id, Integer, required: true
    param :mention, Hash, required: true do
      param :status, ['checked', 'not_checked'], required: true
    end
  end

  doc_for :clear do
    api :PUT, '/mentions/clear', "Clear all mentions by setting status to 'checked'"
    description <<-EOS
      If successful, it returns status <tt>200</tt> with json with <tt>mention object</tt>.

      Mention object contains:
        id: mention Id
        status: status of mention (e.g. 'not_checked', 'checked)
        snoozed: snoozed status - true / false
        updated_at: updated_at
    EOS
  end

  doc_for :snooze do
    api :PUT, '/mentions/snooze', 'Snooze mentions - notification will not be sent for mentions'
    description <<-EOS
      If successful, it returns status <tt>200</tt> with json with <tt>mention object</tt>.

      Mention object contains:
        id: mention Id
        status: status of mention (e.g. 'not_checked', 'checked)
        snoozed: snoozed status - true / false
        updated_at: updated_at
    EOS
    param :mention_ids, Array, of: Integer, desc: 'mention ids to snooze; if not given, all mentions will be snoozed'
  end

  doc_for :unsnooze do
    api :PUT, '/mentions/unsnooze', 'Un-Snooze mentions - notification will be sent for mentions'
    description <<-EOS
      If successful, it returns status <tt>200</tt> with json with <tt>mention object</tt>.

      Mention object contains:
        id: mention Id
        status: status of mention (e.g. 'not_checked', 'checked)
        snoozed: snoozed status - true / false
        updated_at: updated_at
    EOS
    param :mention_ids, Array, of: Integer, desc: 'mention ids to snooze; if not given, all mentions will be snoozed'
  end
end
