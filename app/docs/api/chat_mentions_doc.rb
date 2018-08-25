module Api::ChatMentionsDoc
  extend BaseDoc

  namespace 'api'
  resource :chat_mentions

  doc_for :update do
    api :PUT, '/chat_mentions/:id', 'Update chat mention'
    description <<-EOS
      If successful, it returns status <tt>200</tt> with json with <tt>chat mention object</tt>.
      If wrong parameter is given, it returns status <tt>422</tt>
      If trying to update another user's, it returns status <tt>401</tt>

      Chat Mention object contains:
        id: chat_mention Id
        status: status of chat_mention (e.g. 'not_checked', 'checked)
        updated_at: updated_at
    EOS
    param :id, Integer, required: true
    param :chat_mention, Hash, required: true do
      param :status, ['checked', 'not_checked'], required: true
    end
  end
end
