class TaskItemRecordSerializer < ActiveModel::Serializer
  belongs_to :user
  belongs_to :created_by, serializer: UserSerializer
  belongs_to :updated_by, serializer: UserSerializer

  attributes :id, :completed_at, :comment, :created_at, :updated_at, :title, :image_url

  def image_url
    object.task_item.image.url
  end
end