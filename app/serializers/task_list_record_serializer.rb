class TaskListRecordSerializer < ActiveModel::Serializer
  belongs_to :user
  belongs_to :finished_by
  belongs_to :task_list
  belongs_to :reviewed_by

  attributes :id, :started_at, :status, :notes, :created_at, :updated_at,
             :finished_at, :reviewer_notes, :review_notified_at, :reviewed_at
  attributes :categories, :permission_to, :formatted_finished_at, :formatted_reviewed_at

  def categories
    records = object.task_item_records.category_records.includes(:user, :created_by, :updated_by, :task_item).order(:id)

    records.map { |cr|
      ActiveModelSerializers::SerializableResource.new(cr, {serializer: TaskCategoryRecordSerializer}).as_json
    }
  end

  def formatted_finished_at
    I18n.l(object.finished_at, format: :short_date_and_time) if object.finished_at
  end

  def formatted_reviewed_at
    I18n.l(object.reviewed_at, format: :short_date_and_time) if object.reviewed_at
  end

  def permission_to
    object.task_list.permission_to(scope.current_user)
  end
end
