object @feed
attributes :id, :title, :body, :created_at, :updated_at, :mentioned_user_ids,
           :image_url, :image_width, :image_height, :work_order_id, :room_number,
           :broadcast_start, :broadcast_end, :room_id, :follow_up_start, :follow_up_end
node(:body) { |i| i.body_without_mention_tags }
node(:comments_count) { |feed| feed.replies.count }
node(:created_by) { |feed| partial('api/profile/base', object: feed.created_by) }
node(:work_order_url) { |i| i.work_order.try(:resource_url) }
node(:work_order) { |i| partial('api/work_orders/work_order', object: i.work_order) }
node(:created_by_system) { |i| i.created_by.is_lodgistics_bot? }
node(:room_number) { |feed| feed.room_number }
node(:room_id) { |feed| feed.room&.id }
node(:completed_at) { |feed| feed.completed_at }
node(:completed_by) { |feed| partial('api/profile/base', object: feed.completed_by) }