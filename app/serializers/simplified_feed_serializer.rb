class SimplifiedFeedSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :created_at, :updated_at, :image_url, :image_width, :image_height, :work_order_id

  def image_width
    object.image_width
  end

  def image_height
    object.image_height
  end
end
