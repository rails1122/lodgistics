module Api::FeedsDoc
  extend BaseDoc

  namespace 'api'
  resource :feeds

  doc_for :index do
    api :GET, '/feeds', 'Get hotel feeds'
    description <<-EOS
      If successful, it returns list of <tt>feed</tt> objects with status <tt>200</tt>.

      Feed object contains:
        id: Integer
        title: String
        body: Text
        created_at: String
        updated_at: String
        image_url: String
        image_width: Integer
        image_height: Integer
        comment_count: Integer
        created_by: Object => name, role, avatar
        created_by_system: Boolean
        broadcast_start: String
        broadcast_end: String
        room_number: String
        room_id: Room id
    EOS

    example <<-EOS
GET /api/feeds.json?start_date=2017-06-01&end_date=2017-06-02

[
    {
        "id": 16811,
        "title": null,
        "body": "HEllo world",
        "created_at": "2017-06-02T12:59:59.387-04:00",
        "mentioned_user_ids": [],
        "image_url": "http://placekitten.com/320/200?image=1",
        "image_width": 320,
        "image_height": 200,
        "comments_count": 3,
        "created_by_system": false,
        "created_by": {
            "id": 12,
            "name": "Nikhil N",
            "role": "General Manager",
            "avatar": "/uploads/user/avatar/12/images__4_.jpeg"
        }
    },
    {
        "id": 16810,
        "title": null,
        "body": "@Jacob @Mason testing @mentions",
        "created_at": "2017-06-01T12:53:57.387-04:00",
        "updated_at": "2017-06-01T12:53:57.387-04:00",
        "mentioned_user_ids": [],
        "image_url": "http://placekitten.com/320/200?image=1",
        "image_width": 320,
        "image_height": 200,
        "comments_count": 2,
        "created_by_system": false,
        "created_by": {
            "id": 12,
            "name": "Nikhil N",
            "role": "General Manager",
            "avatar": "/uploads/user/avatar/12/images__4_.jpeg"
        }
    }
]
    EOS

    param :start_date, String, '<tt>mm/dd/yyyy | yyyy-mm-dd</tt> start date in date range.'
    param :end_date, String, '<tt>mm/dd/yyyy | yyyy-mm-dd</tt> end date in date range. should be after start_date, obviously.'
    param :updated_after, String, "returns data updated after given yyyy-mm-dd hh:mm:ss +z. (is08601 format is recommended) if no timezone given, it will be parsed into UTC."
  end

  doc_for :broadcasts do
    api :GET, '/feeds/broadcasts', 'Get hotel broadcast messages'
    description <<-EOS
      If successful, it returns list of <tt>broadcast</tt> objects with status <tt>200</tt>.

      Feed object contains:
        id: Integer
        body: Text
        created_at: String
        updated_at: String
        broadcast_start: String <tt>yyyy-mm-dd</tt>
        broadcast_end: String <tt>yyyy-mm-dd</tt>
        created_by: Object => name, role, avatar
    EOS

    param :date, String, '<tt>mm/dd/yyyy | yyyy-mm-dd</tt> date.'
  end

  doc_for :follow_ups do
    api :GET, '/feeds/follow_ups', 'Get hotel follow_ups messages'
    description <<-EOS
      If successful, it returns list of <tt>feed</tt> objects with status <tt>200</tt>.
    EOS

    param :date, String, '<tt>mm/dd/yyyy | yyyy-mm-dd</tt> date.'
  end

  doc_for :create do
    api :POST, '/feeds', 'Create Feed'
    description <<-EOS
      If successful, it returns feed object with status <tt>201</tt>.
      If any of input params is not correct, it returns error messages with status <tt>422</tt>.
    EOS
    example <<-EOS
POST /api/feeds.json?feed[title]=title&feed[body]=body&image_url="http://placekitten.com/320/200?image=1"&image_width=320&image_height=200
    {
        "id": 16811,
        "title": null,
        "body": "HEllo world",
        "created_at": "2017-06-02T12:59:59.387-04:00",
        "mentioned_user_ids": [],
        "image_url": "http://placekitten.com/320/200?image=1",
        "image_width": 320,
        "image_height": 200,
        "comments_count": 3,
        "created_by_system": false,
        "created_by": {
            "id": 12,
            "name": "Nikhil N",
            "role": "General Manager",
            "avatar": "/uploads/user/avatar/12/images__4_.jpeg"
        }
    },
    EOS

    param :feed, Hash, required: true do
      param :title, String
      param :body, String, required: true
      param :image_url, String, 'url of attached image url'
      param :image_width, Integer, 'image width'
      param :image_height, Integer, 'image height'
      param :parent_id, Integer, 'Main feed id, used when you add comments'
      param :mentioned_user_ids, Array, of: Integer, desc: 'mentioned user ids'
      param :broadcast_start, Date, of: Integer, desc: 'Start date of broadcast'
      param :broadcast_end, Date, of: Integer, desc: 'Start date of broadcast'
      param :follow_up_start, Date, of: Integer, desc: 'Start date of follow up'
      param :follow_up_end, Date, of: Integer, desc: 'Start date of follow up'
    end
  end

  doc_for :show do
    api :GET, '/feeds/:id', 'Get Feed Detail'
    description <<-EOS
      If successful, it returns feed object with status <tt>200</tt>.
      It includes comments with feed object.
    EOS
    param :id, Integer, required: true

    example <<-EOS
GET /api/feeds/20118
{
    "id": 20118,
    "title": null,
    "body": "Please provide food in room108",
    "created_at": "2017-11-21T04:39:41.740-05:00",
    "updated_at": "2017-11-21T05:06:07.000-05:00",
    "mentioned_user_ids": [
        199
    ],
    "image_url": "",
    "image_width": 0,
    "image_height": 0,
    "work_order_id": 3781,
    "comments_count": 2,
    "created_by_system": false,
    "created_by": {
        "id": 200,
        "name": "Akansha",
        "role": "User",
        "title": "FD Manager",
        "avatar": "/uploads/user/avatar/200/images.jpeg",
        "avatar_img_url": "https://lodgistics-development.s3.us-east-2.amazonaws.com/photos/upload/58f6ff95-d086-4f92-9ec6-5206759e64de_200_1507615185795_cdv_photo_001.jpg"
    },
    "work_order_url": "http://dev.lodgistics.com/maintenance/work_orders?id=3781",
    "work_order": {
        "id": 3781,
        "property_id": 33,
        "description": "Please provide food in room108",
        "priority": "m",
        "status": "closed",
        "due_to_date": null,
        "assigned_to_id": 19,
        "maintainable_type": "Maintenance::Room",
        "maintainable_id": 1440,
        "opened_by_user_id": 202,
        "created_at": "2017-11-21T05:03:05.977-05:00",
        "updated_at": "2017-11-21T05:09:04.002-05:00",
        "closed_by_user_id": 199,
        "first_img_url": "",
        "second_img_url": "",
        "location_detail": "Room #104",
        "work_order_url": "http://dev.lodgistics.com/maintenance/work_orders?id=3781"
    },
    "replies": [
        {
            "id": 20120,
            "title": "Work order has been closed",
            "body": "Work order has been closed",
            "created_at": "2017-11-21T05:09:05.231-05:00",
            "updated_at": "2017-11-21T05:09:05.231-05:00",
            "mentioned_user_ids": [],
            "image_url": null,
            "image_width": null,
            "image_height": null,
            "work_order_id": null,
            "comments_count": 0,
            "created_by_system": false,
            "created_by": {
                "id": 228,
                "name": "Lodgistics Bot",
                "role": null,
                "title": null,
                "avatar": "/assets/adminre_theme_v120/image/avatar/avatar.png",
                "avatar_img_url": "https://lodgistics-development.s3.us-east-2.amazonaws.com/photos/upload/97c81616-eb66-45e5-9a81-f0e6985f3de7_199_1508771481266_cdv_photo_001.jpg"
            },
            "work_order_url": null,
            "work_order": null
        },
        {
            "id": 20119,
            "title": null,
            "body": "ok",
            "created_at": "2017-11-21T05:06:07.190-05:00",
            "updated_at": "2017-11-21T05:06:07.190-05:00",
            "mentioned_user_ids": [
                202
            ],
            "image_url": null,
            "image_width": null,
            "image_height": null,
            "work_order_id": null,
            "comments_count": 0,
            "created_by_system": false,
            "created_by": {
                "id": 201,
                "name": "gaurav malviya",
                "role": "Corporate",
                "title": "Admin",
                "avatar": "/uploads/user/avatar/201/negris_avatar.jpg",
                "avatar_img_url": "http://dev.lodgistics.com/uploads/user/avatar/201/negris_avatar.jpg"
            },
            "work_order_url": null,
            "work_order": null
        }
    ]
}
    EOS

  end

  doc_for :update do
    api :PUT, '/feeds/:id', 'Update feed detail'
    description <<-EOS
      If successful, it returns feed object with status <tt>200</tt>.
    EOS
    param :id, Integer, required: true
    param :feed, Hash, required: true do
      param :title, String
      param :body, String, required: true
      param :image_url, String, 'url of attached image url'
      param :image_width, Integer, 'image width'
      param :image_height, Integer, 'image height'
      param :parent_id, Integer, 'Main feed id, used when you add comments'
      param :mentioned_user_ids, Array, of: Integer, desc: 'mentioned user ids'
      param :broadcast_start, Date, of: Integer, desc: 'Start date of broadcast'
      param :broadcast_end, Date, of: Integer, desc: 'Start date of broadcast'
      param :follow_up_start, Date, of: Integer, desc: 'Start date of follow up'
      param :follow_up_end, Date, of: Integer, desc: 'Start date of follow up'
      param :complete, String, 'Complete/Uncomplete feed'
    end
  end

  doc_for :work_orders do
    api :POST, '/feeds/:feed_id/work_orders', 'Create Work Order out of feed'
    error 401, 'Unauthorized'
    error 422, "Unable to create entity (e.g. validation failed)"
    error 500, "Server Error"
    param :feed_id, Integer, desc: 'feed id', required: true
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
    EOS

  end

end
