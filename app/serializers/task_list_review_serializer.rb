class TaskListReviewSerializer < ActiveModel::Serializer
  belongs_to :reviewed_by

  attributes :id, :reviewed_at, :reviewer_notes, :review_notified_at
end