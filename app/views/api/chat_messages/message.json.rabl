object @message

attributes :id, :message, :sender_id, :chat_id, :mentioned_user_ids, :created_at, :updated_at, :image_url,
           :responding_to_chat_message_id, :mention_ids, :work_order_id, :room_number

node(:read) { |m| m.read_by?(current_user) }
node(:reads_count) { |m| m.num_reads }
node(:read_by_user_ids) { |m| m.read_by_user_ids }
node(:work_order_url) { |m| m.work_order.try(:resource_url) }
node(:work_order) { |i| partial('api/work_orders/work_order', object: i.work_order) }
node(:room_id) { |m| m.room&.id }
node(:sender_avatar_img_url) { |m| m.sender.avatar_thumbnail_url }