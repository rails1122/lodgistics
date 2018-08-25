module Api::ChatsDoc
  extend BaseDoc

  namespace 'api'
  resource :chats

  doc_for :index do
    api :GET, '/chats', 'List chats current user is in - grouped by private and group chats'
    error 401, 'Unauthorized'
    error 500, "Server Error"
    param :chat_id, Integer, desc: 'filter by chat id'
    param :is_private, ['true', 'false'], desc: 'if set to true, filter from private chats; if not given, filter from group chats'
    description <<-EOS
      If successful, it returns a list of <tt>chat</tt> object, both private and group, with status <tt>200</tt>.

      chat object contains:
        id: id of chat
        is_already_created: true if already created and saved in db
        is_private: is this a private chat?
        name: Name of chat
        created_at: created datetime
        updated_at: updated datetime
        image_url: image url
        owner_id: user who created this chat
        users: users in this chat
          id: User id
          name: User name
          avatar: User avatar urls(default, small, medium thumbnails)
          joined_at: Timestamp when user joined group
        last_message: Last message of group
          id: Message Id
          sender_id: User who sent this message
          message: Message Content
          mentioned_user_ids: List of mentioned user ids
          created_at: Message created time
          image_url: Image url
        unread: Unread message count
    EOS
  end

  doc_for :create do
    api :POST, '/chats', 'Create chat - same api used for both private and group chat'
    error 401, 'Unauthorized'
    error 422, "Unable to create entity (e.g. validation failed)"
    error 500, "Server Error"
    param :chat, Hash, desc: 'chat info', required: true do
      param :is_private, ['true', 'false'], desc: "'true' if this is a private chat"
      param :name, String, desc: 'chat name. Can be omitted for private chat but required for group chat'
      param :image_url, String, desc: 'URL for image'
      param :user_ids, Array, of: Integer, desc: 'User ids who are in this chat'
    end
    description <<-EOS
      If successful, it returns <tt>chat</tt> object with status <tt>201</tt>.

      chat object contains:
        id: id of chat
        is_already_created: true if already created and saved in db
        is_private: is this a private chat?
        name: Name of chat
        created_at: created datetime
        updated_at: updated datetime
        image_url: image url
        owner_id: user who created this chat
        users: users in this chat
          id: User id
          name: User name
          avatar: User avatar urls(default, small, medium thumbnails)
          joined_at: Timestamp when user joined group
        last_message: Last message of group
          id: Message Id
          sender_id: User who sent this message
          message: Message Content
          mentioned_user_ids: List of mentioned user ids
          created_at: Message created time
          image_url: Image url
        unread: Unread message count
    EOS
  end

  doc_for :update do
    api :PUT, '/chats/:id', 'Update chat - same api used for both private and group chat'
    error 401, 'Unauthorized'
    error 404, 'Not Found'
    error 422, "Unable to update entity (e.g. validation failed)"
    error 500, "Server Error"
    description <<-EOS
      If successful, it returns <tt>chat</tt> object with status <tt>200</tt>.

      chat object contains:
        id: id of chat
        is_already_created: true if already created and saved in db
        is_private: is this a private chat?
        name: Name of chat
        created_at: created datetime
        updated_at: updated datetime
        image_url: image url
        owner_id: user who created this chat
        users: users in this chat
          id: User id
          name: User name
          avatar: User avatar urls(default, small, medium thumbnails)
          joined_at: Timestamp when user joined group
        last_message: Last message of group
          id: Message Id
          sender_id: User who sent this message
          message: Message Content
          mentioned_user_ids: List of mentioned user ids
          created_at: Message created time
          image_url: Image url
        unread: Unread message count
    EOS
    param :chat, Hash, desc: 'chat info', required: true do
      param :name, String, desc: 'chat name. Can be omitted for private chat but required for group chat'
      param :image_url, String, desc: 'URL for image'
      param :user_ids, Array, of: Integer, desc: 'User ids who are in this chat \n in case of private chat room, you cannot update user_ids'
    end
  end

  doc_for :private_only do
    api :GET, '/chats/private_only', 'List private chats current user is in'
    error 401, 'Unauthorized'
    error 500, "Server Error"
    param :chat_id, Integer, desc: 'filter by chat id'
    description <<-EOS
      If successful, it returns a list of object that contains a private <tt>chat</tt> object with key 'chat' and a <tt>user</tt> object with key 'target_user, with status <tt>200</tt>.

      chat object contains:
        id: id of chat
        is_already_created: true if already created and saved in db
        is_private: is this a private chat?
        name: Name of chat
        created_at: created datetime
        updated_at: updated datetime
        image_url: image url
        owner_id: user who created this chat
        users: users in this chat
          id: User id
          name: User name
          avatar: User avatar urls(default, small, medium thumbnails)
          joined_at: Timestamp when user joined group
        last_message: Last message of group
          id: Message Id
          sender_id: User who sent this message
          message: Message Content
          mentioned_user_ids: List of mentioned user ids
          created_at: Message created time
          image_url: Image url
        unread: Unread message count

      user object contains:
        id: id of user
        name: name of user
        email: email address of user
        avatar:
          url: url for avatar
          thumb: url for thumbnail
          medium: url for medium sized image
    EOS
    example <<-EOS
[
    {
      "target_user": {
          "id": 198,
          "name": "Melissa @ AGM",
          "email": "nikhilnatu+galaxy.test@gmail.com",
          "avatar": {
              "url": "/uploads/user/avatar/198/images.jpeg",
              "thumb": {
                  "url": "/uploads/user/avatar/198/thumb_images.jpeg"
              },
              "medium": {
                  "url": "/uploads/user/avatar/198/medium_images.jpeg"
              }
          },
      },
      'chat': {
        "id": 381,
        "is_already_created": true,
        "is_private": true,
        "name": "PRIVATE chat",
        "created_at": "2017-07-06T23:31:55.777-04:00",
        "updated_at": "2017-07-06T23:31:55.777-04:00",
        "owner_id": 199,
        "users": [
            {
                "joined_at": "2017-07-06T23:31:55.791-04:00",
                "id": 199,
                "name": "Animesh Jain",
                "avatar": {
                    "url": "/uploads/user/avatar/199/zn178412.jpg",
                    "medium": "/uploads/user/avatar/199/medium_zn178412.jpg",
                    "thumb": "/uploads/user/avatar/199/thumb_zn178412.jpg"
                }
            },
            {
                "joined_at": "2017-07-06T23:31:55.785-04:00",
                "id": 198,
                "name": "Melissa @ AGM",
                "avatar": {
                    "url": "/uploads/user/avatar/198/images.jpeg",
                    "medium": "/uploads/user/avatar/198/medium_images.jpeg",
                    "thumb": "/uploads/user/avatar/198/thumb_images.jpeg"
                }
            }
        ],
        "last_message": null,
        "unread": 0
      }
    },
    {
      "target_user": {
          "id": 200,
          "name": "Akanksha A",
          "email": "akansha.agarwal@galaxyweblinks.in",
          "avatar": {
              "url": "/uploads/user/avatar/200/images.jpeg",
              "thumb": {
                  "url": "/uploads/user/avatar/200/thumb_images.jpeg"
              },
              "medium": {
                  "url": "/uploads/user/avatar/200/medium_images.jpeg"
              }
          },
      },
      'chat': {
        "id": 382,
        "is_already_created": true,
        "is_private": true,
        "name": "PRIVATE chat",
        "created_at": "2017-07-06T23:32:17.192-04:00",
        "updated_at": "2017-07-07T02:58:01.664-04:00",
        "owner_id": 199,
        "users": [
            {
                "joined_at": "2017-07-06T23:32:17.203-04:00",
                "id": 199,
                "name": "Animesh Jain",
                "avatar": {
                    "url": "/uploads/user/avatar/199/zn178412.jpg",
                    "medium": "/uploads/user/avatar/199/medium_zn178412.jpg",
                    "thumb": "/uploads/user/avatar/199/thumb_zn178412.jpg"
                }
            },
            {
                "joined_at": "2017-07-06T23:32:17.198-04:00",
                "id": 200,
                "name": "Akanksha A",
                "avatar": {
                    "url": "/uploads/user/avatar/200/images.jpeg",
                    "medium": "/uploads/user/avatar/200/medium_images.jpeg",
                    "thumb": "/uploads/user/avatar/200/thumb_images.jpeg"
                }
            }
        ],
        "last_message": {
            "id": 3299,
            "sender_id": 199,
            "message": "hello",
            "created_at": "2017-07-07T02:58:01.662-04:00",
            "mentioned_user_ids": []
        },
        "unread": 0
      }
    },
    {
      "target_user": {
          "id": 202,
          "name": "Abhishek S",
          "email": "abhishek.sharma@galaxyweblinks.in",
          "avatar": {
              "url": "/uploads/user/avatar/202/images__4_.jpeg",
              "thumb": {
                  "url": "/uploads/user/avatar/202/thumb_images__4_.jpeg"
              },
              "medium": {
                  "url": "/uploads/user/avatar/202/medium_images__4_.jpeg"
              }
          },
      },
      'chat': {
        "id": null,
        "is_already_created": false,
        "is_private": true,
        "name": null,
        "created_at": null,
        "updated_at": null,
        "owner_id": 199,
        "users": [
            {
                "joined_at": null,
                "id": 202,
                "name": "Abhishek S",
                "avatar": {
                    "url": "/uploads/user/avatar/202/images__4_.jpeg",
                    "medium": "/uploads/user/avatar/202/medium_images__4_.jpeg",
                    "thumb": "/uploads/user/avatar/202/thumb_images__4_.jpeg"
                }
            },
            {
                "joined_at": null,
                "id": 199,
                "name": "Animesh Jain",
                "avatar": {
                    "url": "/uploads/user/avatar/199/zn178412.jpg",
                    "medium": "/uploads/user/avatar/199/medium_zn178412.jpg",
                    "thumb": "/uploads/user/avatar/199/thumb_zn178412.jpg"
                }
            }
        ],
        "last_message": null,
        "unread": 0
      }
    }
]
    EOS
  end

  doc_for :group_only do
    api :GET, '/chats/group_only', 'List group (e.g. non private) chats current user is in'
    error 401, 'Unauthorized'
    error 500, "Server Error"
    param :chat_id, Integer, desc: 'filter by chat id'
    description <<-EOS
      If successful, it returns a list of object that contains a <tt>chat</tt> object with key 'chat', with status <tt>200</tt>.

      chat object contains:
        id: id of chat
        is_already_created: true if already created and saved in db
        is_private: is this a private chat?
        name: Name of chat
        created_at: created datetime
        updated_at: updated datetime
        owner_id: user who created this chat
        users: users in this chat
          id: User id
          name: User name
          avatar: User avatar urls(default, small, medium thumbnails)
          joined_at: Timestamp when user joined group
        last_message: Last message of group
          id: Message Id
          sender_id: User who sent this message
          message: Message Content
          mentioned_user_ids: List of mentioned user ids
          created_at: Message created time
          image_url: Image url
        unread: Unread message count
    EOS
    example <<-EOS
[
    {
      'chat': {
          "id": 379,
          "is_already_created": true,
          "is_private": false,
          "name": "TEST chat",
          "created_at": "2017-07-06T22:49:43.133-04:00",
          "updated_at": "2017-07-07T11:03:10.346-04:00",
          "owner_id": 199,
          "users": [
              {
                  "joined_at": "2017-07-06T22:49:43.146-04:00",
                  "id": 199,
                  "name": "Animesh Jain",
                  "avatar": {
                      "url": "/uploads/user/avatar/199/zn178412.jpg",
                      "medium": "/uploads/user/avatar/199/medium_zn178412.jpg",
                      "thumb": "/uploads/user/avatar/199/thumb_zn178412.jpg"
                  }
              },
              {
                  "joined_at": "2017-07-06T22:49:43.142-04:00",
                  "id": 198,
                  "name": "Melissa @ AGM",
                  "avatar": {
                      "url": "/uploads/user/avatar/198/images.jpeg",
                      "medium": "/uploads/user/avatar/198/medium_images.jpeg",
                      "thumb": "/uploads/user/avatar/198/thumb_images.jpeg"
                  }
              }
          ],
          "last_message": {
              "id": 3302,
              "sender_id": 199,
              "message": "good",
              "created_at": "2017-07-07T11:03:10.341-04:00",
              "mentioned_user_ids": []
          },
          "unread": 0
      }
    },
    {
      'chat': {
        "id": 383,
        "is_already_created": true,
        "is_private": false,
        "name": "Tt",
        "created_at": "2017-07-07T04:42:00.016-04:00",
        "updated_at": "2017-07-07T04:45:31.732-04:00",
        "owner_id": 199,
        "users": [
            {
                "joined_at": "2017-07-07T04:42:00.048-04:00",
                "id": 199,
                "name": "Animesh Jain",
                "avatar": {
                    "url": "/uploads/user/avatar/199/zn178412.jpg",
                    "medium": "/uploads/user/avatar/199/medium_zn178412.jpg",
                    "thumb": "/uploads/user/avatar/199/thumb_zn178412.jpg"
                }
            },
            {
                "joined_at": "2017-07-07T04:42:00.043-04:00",
                "id": 202,
                "name": "Abhishek S",
                "avatar": {
                    "url": "/uploads/user/avatar/202/images__4_.jpeg",
                    "medium": "/uploads/user/avatar/202/medium_images__4_.jpeg",
                    "thumb": "/uploads/user/avatar/202/thumb_images__4_.jpeg"
                }
            },
            {
                "joined_at": "2017-07-07T04:42:00.038-04:00",
                "id": 200,
                "name": "Akanksha A",
                "avatar": {
                    "url": "/uploads/user/avatar/200/images.jpeg",
                    "medium": "/uploads/user/avatar/200/medium_images.jpeg",
                    "thumb": "/uploads/user/avatar/200/thumb_images.jpeg"
                }
            },
            {
                "joined_at": "2017-07-07T04:42:00.029-04:00",
                "id": 201,
                "name": "Gaurav M",
                "avatar": {
                    "url": "/uploads/user/avatar/201/negris_avatar.jpg",
                    "medium": "/uploads/user/avatar/201/medium_negris_avatar.jpg",
                    "thumb": "/uploads/user/avatar/201/thumb_negris_avatar.jpg"
                }
            }
        ],
        "last_message": {
            "id": 3301,
            "sender_id": 199,
            "message": "<img src='https://lodgistics-development.s3.us-east-2.amazonaws.com/photos/upload/937d31fb-75ea-45f4-85d4-fe9c4c318ee6_199_1499417128203_cdv_photo_001.jpg'/><br/>Hi",
            "created_at": "2017-07-07T04:45:31.730-04:00",
            "mentioned_user_ids": []
        },
        "unread": 0
      }
    }
]
    EOS
  end

  doc_for :messages do
    api :GET, '/chats/:id/messages', 'List messages in given chat'
    error 401, 'Unauthorized'
    error 404, 'Not Found'
    error 500, "Server Error"
    param :start_date, String, desc: 'yyyy-mm-dd; if given, returns messages created on and after this date'
    param :end_date, String, desc: 'yyyy-mm-dd; if given, returns messages created on and before this date'
    param :message_id, Integer, desc: 'message_id; if given, returns messages with id > given message_id'
    description <<-EOS
      If successful, it returns a list of <tt>chat_message</tt> object with status <tt>200</tt>.

      chat_message object contains:
        id: Message Id
        message: Message Content
        sender_id: User who sent this message
        chat_id: chat id
        mentioned_user_ids: List of mentioned user ids
        reads_count: read count of this message
        read: true if this message was read by current user
        read_by_user_ids: user ids who read this message
        image_url: image url attached to this message
        created_at: created time
        updated_at: updated time
    EOS
    example <<-EOS
[
  {
      "id": 123,
      "message": "hello_world_a",
      "sender_id": 199,
      "chat_id": 383,
      "mentioned_user_ids": [],
      "reads_count": 1,
      "read": true,
      "read_by_user_ids": [199],
      "image_url": "http://placekitten.com/320/200?image=1",
      "created_at": "2017-08-01T16:22:38.240-04:00"
      "updated_at": "2017-08-02T16:22:38.240-04:00"
  },
  {
      "id": 124,
      "message": "hello_world_b",
      "sender_id": 199,
      "chat_id": 383,
      "mentioned_user_ids": [],
      "reads_count": 1,
      "read": true,
      "read_by_user_ids": [199],
      "image_url": "http://placekitten.com/320/200?image=1",
      "created_at": "2017-08-01T16:22:38.240-04:00"
      "updated_at": "2017-08-02T16:22:38.240-04:00"
  }
]
    EOS
  end

end
