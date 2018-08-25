class TaskItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :image_url, :created_at, :updated_at

  def image_url
    object.image.url
  end
end