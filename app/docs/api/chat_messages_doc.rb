module Api::ChatMessagesDoc
  extend BaseDoc

  namespace 'api'
  resource :chat_messages

  doc_for :index do
    api :GET, '/chat_messages', 'Get chat_message list'
    description <<-EOS
      If successful, it returns <tt>chat_message list</tt> with status <tt>2010</tt>.
      Messages are classified with group id, so response should be JSON object with this format.
        {
          group_id => [chat_message list],
          group_id => [chat_message list],
          ...
        }

      chat_message object contains:
        id: Message Id
        message: Message Content
        sender_id: User who sent this message
        chat_id: chat id
        mentioned_user_ids: List of mentioned user ids
        mention_ids: List of mention record ids
        reads_count: read count of this message
        read: true if this message was read by current user
        read_by_user_ids: user ids who read this message
        image_url: image url attached to this message
        created_at: created time
        updated_at: updated time
        work_order: work order information
    EOS
    param :type, ['group', 'private'], required: true, desc: 'Get group/private chat messages'
    param :id, ['all', 'any group/private id'], required: true, desc: 'Group/private chat id or string "all"'
    param :last_id, Integer, desc: 'Last chat_message id you want to retrieve from'
    param :from, String, desc: 'Date string to search from, <tt>yyyy-mm-dd</tt>, <tt>mm/dd/yyyy</tt>. Default: today'
    param :to, String, desc: 'Date string to search from, <tt>yyyy-mm-dd</tt>, <tt>mm/dd/yyyy</tt>. Default: today'
  end

  doc_for :updates do
    api :GET, '/chat_messages/updates', 'Get a list of chat message objects for given chat message ids'
    description <<-EOS
      If successful, it returns a list of<tt>chat_message</tt> with status <tt>2010</tt>.

      chat_message object contains:
        id: Message Id
        message: Message Content
        sender_id: User who sent this message
        chat_id: chat id
        mentioned_user_ids: List of mentioned user ids
        mention_ids: List of mention record ids
        reads_count: read count of this message
        read: true if this message was read by current user
        read_by_user_ids: user ids who read this message
        image_url: image url attached to this message
        created_at: created time
        updated_at: updated time
        work_order: work order information
    EOS
    example <<-EOS
GET /api/chat_messages/updates?chat_mesage_ids[]=123

[
  {
      "id": 123,
      "message": "hello_world_a",
      "sender_id": 199,
      "chat_id": 383,
      "mentioned_user_ids": [],
      "mention_ids": [],
      "reads_count": 1,
      "read": true,
      "read_by_user_ids": [199],
      "image_url": "http://placekitten.com/320/200?image=1",
      "created_at": "2017-08-01T16:22:38.240-04:00",
      "updated_at": "2017-08-02T16:22:38.240-04:00",
      "work_order": {}
  }
]
    EOS
    param 'chat_message_ids[]', Array, of: Integer, desc: "chat message ids - e.g. ?chat_message_ids[]=123&chat_message_ids[]=456"
  end

  doc_for :show do
    api :GET, '/chat_messages/:id', 'Get chat message info'
    error 401, "Unauthorized (e.g. current user has no access to chat message - not in the chat this message belongs to)"
    error 404, 'chat message not found'
    error 500, "Server Error"

    description <<-EOS
      If successful, it returns chat_message object with status <tt>201</tt>.
      If any of input params is not correct, it returns error messages with status <tt>422</tt>.

      chat_message object contains:
        id: Message Id
        message: Message Content
        sender_id: User who sent this message
        chat_id: chat id
        mentioned_user_ids: List of mentioned user ids
        mention_ids: List of mention record ids
        reads_count: read count of this message
        read: true if this message was read by current user
        read_by_user_ids: user ids who read this message
        image_url: image url attached to this message
        created_at: created time
        updated_at: updated time
        work_order: work order information
    EOS
    example <<-EOS
GET /api/chat_messages/123

{
    "id": 123,
    "message": "hello_world_a",
    "sender_id": 199,
    "chat_id": 383,
    "mentioned_user_ids": [],
    "mention_ids": [],
    "reads_count": 1,
    "read": true,
    "read_by_user_ids": [199],
    "image_url": "http://placekitten.com/320/200?image=1",
    "created_at": "2017-08-01T16:22:38.240-04:00",
    "updated_at": "2017-08-02T16:22:38.240-04:00",
    "work_order": {}
}
    EOS
    param :id, Integer, required: true
  end

  doc_for :create do
    api :POST, '/chat_messages', 'Create A Chat Message'
    description <<-EOS
      If successful, it returns chat_message object with status <tt>201</tt>.
      If any of input params is not correct, it returns error messages with status <tt>422</tt>.

      chat_message object contains:
        id: Message Id
        message: Message Content
        sender_id: User who sent this message
        chat_id: chat id
        mentioned_user_ids: List of mentioned user ids
        mention_ids: List of mention record ids
        reads_count: read count of this message
        read: true if this message was read by current user
        read_by_user_ids: user ids who read this message
        image_url: image url attached to this message
        created_at: created time
        updated_at: updated time
        work_order: work order information
    EOS
    example <<-EOS
POST /api/chat_messages?chat_message[message]=hello_world_a&chat_message[chat_id]=383&chat_message[image_url]="http://placekitten.com/320/200?image=1"

{
    "id": 123,
    "message": "hello_world_a",
    "sender_id": 199,
    "chat_id": 383,
    "mentioned_user_ids": [],
    "mention_ids": [],
    "reads_count": 1,
    "read": true,
    "read_by_user_ids": [199],
    "image_url": "http://placekitten.com/320/200?image=1",
    "created_at": "2017-08-01T16:22:38.240-04:00",
    "updated_at": "2017-08-02T16:22:38.240-04:00",
    "work_order": {}
}
    EOS
    param :chat_message, Hash, required: true do
      param :message, String
      param :chat_id, Integer, required: true, desc: 'chat id - if current user is not in this chat, request will not be processed'
      param :image_url, String, desc: 'attached image url'
      param :mentioned_user_ids, Array, of: Integer, desc: 'mentioned user ids'
    end
  end

  doc_for :mark_read do
    api :PUT, '/chat_messages/:id/mark_read', 'Mark given chat message as read by current user'
    error 401, "Unauthorized (e.g. current user is not in the chat this message belongs to)"
    error 404, 'chat message not found'
    error 500, "Server Error"

    description <<-EOS
      If successful, it returns chat_message object with status <tt>201</tt>.

      chat_message object contains:
        id: Message Id
        message: Message Content
        sender_id: User who sent this message
        chat_id: chat id
        mentioned_user_ids: List of mentioned user ids
        mention_ids: List of mention record ids
        reads_count: read count of this message
        read: true if this message was read by current user
        read_by_user_ids: user ids who read this message
        image_url: image url attached to this message
        created_at: created time
        updated_at: updated time
        work_order: work order information
    EOS
    example <<-EOS
PUT /api/chat_messages/123/mark_read

{
    "id": 123,
    "message": "hello_world_a",
    "sender_id": 199,
    "chat_id": 383,
    "mentioned_user_ids": [],
    "mention_ids": [],
    "reads_count": 1,
    "read": true,
    "read_by_user_ids": [199],
    "image_url": "http://placekitten.com/320/200?image=1",
    "created_at": "2017-08-01T16:22:38.240-04:00",
    "updated_at": "2017-08-02T16:22:38.240-04:00",
    "work_order": {}
}
    EOS
    param :id, Integer, required: true
  end

  doc_for :mark_read_mass do
    api :PUT, '/chat_messages/mark_read_mass', 'Mark given chat message ids as read by current user'
    error 401, "Unauthorized (e.g. current user is not in the chat one of requested messages belongs to)"
    error 500, "Server Error"

    description <<-EOS
      If successful, it returns a list chat_message object with status <tt>201</tt>.

      chat_message object contains:
        id: Message Id
        message: Message Content
        sender_id: User who sent this message
        chat_id: chat id
        mentioned_user_ids: List of mentioned user ids
        mention_ids: List of mention record ids
        reads_count: read count of this message
        read: true if this message was read by current user
        read_by_user_ids: user ids who read this message
        image_url: image url attached to this message
        created_at: created time
        updated_at: updated time
        work_order: work order information
    EOS
    example <<-EOS
PUT /api/chat_messages/mark_read_mass?chat_message_ids[]=123
[
  {
      "id": 123,
      "message": "hello_world_a",
      "sender_id": 199,
      "chat_id": 383,
      "mentioned_user_ids": [],
      "mention_ids": [],
      "reads_count": 1,
      "read": true,
      "read_by_user_ids": [199],
      "image_url": "http://placekitten.com/320/200?image=1",
      "created_at": "2017-08-01T16:22:38.240-04:00",
      "updated_at": "2017-08-02T16:22:38.240-04:00",
      "work_order": {}
  }
]
    EOS
    param 'chat_message_ids[]', Array, of: Integer, desc: "chat message ids - e.g. ?chat_message_ids[]=123&chat_message_ids[]=456"
  end

  doc_for :work_orders do
    api :POST, '/chat_messages/:chat_message_id/work_orders', 'Create Work Order out of feed'
    error 401, 'Unauthorized'
    error 422, "Unable to create entity (e.g. validation failed)"
    error 500, "Server Error"
    param :chat_message_id, Integer, desc: 'chat message id', required: true
    param :work_order, Hash, desc: 'work order parameter', required: true do
      param :description, String, desc: 'description'
      param :priority, String, desc: 'priority - l, m, h'
      param :status, String, desc: 'status - open, closed, working'
      param :due_to_date, String, desc: 'due date - yyyy-mm-dd'
      param :assigned_to_id, Integer, desc: 'user id whom this work order is assigned to'
      param :maintainable_type, String, desc: "Type of maintainable - e.g. 'Room', 'Other', 'Equipment', 'PublicArea'"
      param :maintainable_id, Integer, desc: 'maintainable id'
      param :maintenance_checklist_item_id, Integer, desc: 'checklist item id'
      param :first_img_url, String, desc: 'img url for 1st img'
      param :second_img_url, String, desc: 'img url for 2nd img'
    end

    description <<-EOS
      If successful, it returns a json containing <tt>work_order object</tt>

      WorkOrder object contains:
        id: id of work_order
        property_id: property_id of this work_order
        description: content/description
        priority: priority
        status: status
        due_to_date: due date
        assigned_to_id: user_id of this work_order is assigned to
        maintainable_type: maintainable_type
        maintainable_id: maintainable_id
        opened_by_user_id: user_id who opened this work_order
        created_at: created_at
        updated_at: updated_at
        work_order: work order information
    EOS

  end

end
