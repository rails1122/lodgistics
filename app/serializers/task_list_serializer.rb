class TaskListSerializer < ActiveModel::Serializer
  belongs_to :created_by, serializer: UserSerializer
  belongs_to :updated_by, serializer: UserSerializer

  attributes :id, :name, :description, :notes, :created_at, :updated_at
end