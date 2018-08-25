module Api::AcknowledgementsDoc
  extend BaseDoc

  namespace 'api'
  resource :acknowledgements

  doc_for :index do
    api :GET, '/acknowledgements', 'Get acknowledgement list created or received by current user'
    description <<-EOS
      If successful, it returns list of <tt>acknowledgement</tt> with status <tt>201</tt>.

      acknowledgement object contains:
        id: id
        user_id: user who created this record
        target_user_id: whom this targets at
        checked_at: when it was checked by target_user
        created_at: created datetime
        updated_at: created datetime
        acknowledeable_type: type of acknowledeable item - ChatMessage or Engage::Message(feed)
        acknowledeable_id: id of feed or chat_message
    EOS
    example <<-EOS
GET /api/acknowledgements

[
  {
      "id": 123,
      "user_id: 199
      "target_user_id": 200
      "checked_at": "2017-08-02T16:22:38.240-04:00"
      "created_at": "2017-08-01T16:22:38.240-04:00"
      "updated_at": "2017-08-02T16:22:38.240-04:00"
      "acknowledeable_type": 'ChatMessage',
      "acknowledeable_id": 3409
  }
]
    EOS
    error 500, "Server Error"
  end

  doc_for :received do
    api :GET, '/acknowledgements/received', 'Get acknowledgement list received by current user'
    description <<-EOS
      If successful, it returns list of <tt>acknowledgement</tt> with status <tt>201</tt>.

      acknowledgement object contains:
        id: id
        user_id: user who created this record
        target_user_id: whom this targets at
        checked_at: when it was checked by target_user
        created_at: created datetime
        updated_at: created datetime
        acknowledeable_type: type of acknowledeable item - ChatMessage or Engage::Message(feed)
        acknowledeable_id: id of feed or chat_message
    EOS
    example <<-EOS
GET /api/acknowledgements/received

[
  {
      "id": 123,
      "user_id: 199
      "target_user_id": 200
      "checked_at": "2017-08-02T16:22:38.240-04:00"
      "created_at": "2017-08-01T16:22:38.240-04:00"
      "updated_at": "2017-08-02T16:22:38.240-04:00"
      "acknowledeable_type": 'ChatMessage',
      "acknowledeable_id": 3409
  }
]
    EOS
    error 500, "Server Error"
  end

  doc_for :sent do
    api :GET, '/acknowledgements/sent', 'Get acknowledgement list sent by current user'
    description <<-EOS
      If successful, it returns list of <tt>acknowledgement</tt> with status <tt>201</tt>.

      acknowledgement object contains:
        id: id
        user_id: user who created this record
        target_user_id: whom this targets at
        checked_at: when it was checked by target_user
        created_at: created datetime
        updated_at: created datetime
        acknowledeable_type: type of acknowledeable item - ChatMessage or Engage::Message(feed)
        acknowledeable_id: id of feed or chat_message
    EOS
    example <<-EOS
GET /api/acknowledgements/received

[
  {
      "id": 123,
      "user_id: 199
      "target_user_id": 200
      "checked_at": "2017-08-02T16:22:38.240-04:00"
      "created_at": "2017-08-01T16:22:38.240-04:00"
      "updated_at": "2017-08-02T16:22:38.240-04:00"
      "acknowledeable_type": 'ChatMessage',
      "acknowledeable_id": 3409
  }
]
    EOS
    error 500, "Server Error"
  end


  doc_for :show do
    api :GET, '/acknowledgements/:id', 'Get acknowledgement info'
    description <<-EOS
      If successful, it returns <tt>acknowledgement</tt> object with status <tt>200</tt>.

      acknowledgement object contains:
        id: id
        user_id: user who created this record
        target_user_id: whom this targets at
        checked_at: when it was checked by target_user
        created_at: created datetime
        updated_at: created datetime
        acknowledeable_type: type of acknowledeable item - ChatMessage or Engage::Message(feed)
        acknowledeable_id: id of feed or chat_message
    EOS
    example <<-EOS
GET /api/acknowledgements/123

  {
      "id": 123,
      "user_id: 199
      "target_user_id": 200
      "checked_at": "2017-08-02T16:22:38.240-04:00"
      "created_at": "2017-08-01T16:22:38.240-04:00"
      "updated_at": "2017-08-02T16:22:38.240-04:00"
      "acknowledeable_type": 'ChatMessage',
      "acknowledeable_id": 3409
  }
    EOS
    error 400, "Not Found"
    error 401, "Unauthorized (e.g. not authorized to access this item)"
    error 500, "Server Error"
  end

  doc_for :create do
    api :POST, '/acknowledgements', 'Create an acknowledgements'
    description <<-EOS
      If successful, it returns <tt>acknowledgement</tt> object with status <tt>200</tt>.

      acknowledgement object contains:
        id: id
        user_id: user who created this record
        target_user_id: whom this targets at
        checked_at: when it was checked by target_user
        created_at: created datetime
        updated_at: created datetime
        acknowledeable_type: type of acknowledeable item - ChatMessage or Engage::Message(feed)
        acknowledeable_id: id of feed or chat_message
    EOS
    example <<-EOS
POST /api/acknowledgements?acknowledgement[target_user_id]=200&acknowledgement[acknowledeable_type]=ChatMessage&acknowledgement[acknowledeable_id]=3409

{
      "id": 123,
      "user_id: 199
      "target_user_id": 200
      "checked_at": null
      "created_at": "2017-08-01T16:22:38.240-04:00"
      "updated_at": "2017-08-02T16:22:38.240-04:00"
      "acknowledeable_type": 'ChatMessage',
      "acknowledeable_id": 3409
}
    EOS
    param :acknowledgement, Hash, required: true do
      param :target_user_id, Integer, required: true, desc: 'target user'
      param :acknowledeable_id, Integer, required: true, desc: 'feed or chat_message id'
      param :acknowledeable_type, String, required: true, desc: 'acknowledeable type - ChatMessage / Engage::Message'
      param :snooze_mention, ['true', 'false'], required: false, desc: 'if set to true, snooze notification for mentions in chat_message / feed'
    end
  end
end
