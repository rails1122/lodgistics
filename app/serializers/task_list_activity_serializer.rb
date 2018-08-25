class TaskListActivitySerializer < ActiveModel::Serializer
  attributes :id, :finished_at, :status, :reviewer_notes, :reviewed_at, :formatted_finished_at, :formatted_reviewed_at
  attributes :permission_to, :day_finished_at, :incomplete_count, :total_count

  belongs_to :finished_by, serializer: UserSerializer
  belongs_to :task_list
  belongs_to :reviewed_by, serializer: UserSerializer

  def formatted_finished_at
    I18n.l(object.finished_at, format: :short_date_and_time)
  end

  def formatted_reviewed_at
    I18n.l(object.reviewed_at, format: :short_date_and_time) if object.reviewed_at
  end

  def day_finished_at
    I18n.l(object.finished_at, format: :mini)
  end

  def total_count
    object.task_item_records.items.count
  end

  def incomplete_count
    object.task_item_records.items.incomplete.count
  end

  def permission_to
    object.task_list.permission_to(scope.current_user)
  end
end
