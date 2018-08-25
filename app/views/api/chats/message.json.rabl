object @message

attributes :id, :sender_id, :message, :created_at, :image_url, :mentioned_user_ids, :room_number, :room_id

node(:room_id) { |m| m.room&.id }