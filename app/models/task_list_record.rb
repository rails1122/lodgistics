class TaskListRecord < ApplicationRecord
  include PropertyScopable

  belongs_to :user
  belongs_to :task_list
  belongs_to :finished_by, class_name: 'User', foreign_key: :finished_by_id
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by_id
  belongs_to :reviewed_by, class_name: 'User', foreign_key: :reviewed_by_id
  has_many :task_item_records, dependent: :destroy

  scope :not_started, -> { where.not(status: TaskListRecord.statuses[:started]) }
  scope :completed, -> { where(status: [TaskListRecord.statuses[:finished], TaskListRecord.statuses[:finished_incomplete]]) }
  scope :finished_after, -> (d) { where('finished_at < ?', d) if d.present? }

  enum status: {
      started: 0,
      finished: 10,
      finished_incomplete: 20,
      reviewed: 30
  }

  def all_completed?
    task_item_records.incomplete.count == 0
  end

  def finish!(user, params = {})
    self.finished_at = Time.current
    self.notes = params[:notes] unless params[:notes].blank?
    self.status = all_completed? ? TaskListRecord.statuses[:finished] : TaskListRecord.statuses[:finished_incomplete]
    self.finished_by = user

    self.save!
  end

  def review?(user)
    finished_status? && (task_list.permission_to(user) == 'review')
  end

  def finished_status?
    !started?
  end
end
