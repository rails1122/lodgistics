class ChatMessageSerializer < ActiveModel::Serializer
  attributes :id, :message, :sender_id, :chat_id, :reads_count, :read, :read_by_user_ids,
    :updated_at, :image_url, :responding_to_chat_message_id, :created_at,
    :mention_ids, :mentioned_user_ids, :sender_avatar_img_url, :room_number, :room_id,
    :work_order_id, :work_order, :work_order_url

  belongs_to :work_order

  def sender_avatar_img_url
    object.sender.avatar_thumbnail_url
  end

  def message
    object.message_content
  end

  def read
    object.read_by?(instance_options[:current_user])
  end

  def read_by_user_ids
    object.read_by_user_ids
  end

  def mention_ids
    object.mention_ids
  end

  def mentioned_user_ids
    object.mentioned_user_ids
  end

  def room_id
    object.room&.id
  end

  def work_order_url
    object.work_order&.resource_url
  end
end
