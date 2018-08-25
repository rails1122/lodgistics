class TaskList < ApplicationRecord
  include PropertyScopable

  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by_id
  has_many :task_items, dependent: :destroy
  has_many :task_list_roles, dependent: :destroy
  has_many :task_list_records, dependent: :destroy
  has_many :assignable_roles, -> { assignable }, class_name: 'TaskListRole', foreign_key: :task_list_id
  has_many :reviewable_roles, -> { reviewable }, class_name: 'TaskListRole', foreign_key: :task_list_id

  accepts_nested_attributes_for :assignable_roles, allow_destroy: true, reject_if: lambda { |c| c[:department_id].blank? || c[:role_id].blank? }
  accepts_nested_attributes_for :reviewable_roles, allow_destroy: true, reject_if: lambda { |c| c[:department_id].blank? || c[:role_id].blank? }

  validates :name, :description, presence: true

  scope :active, -> { where(inactivated_by_id: nil) }
  scope :inactive, -> { where.not(inactivated_by_id: nil) }

  def assignable_users
    roles = task_list_roles.assignable
    User.by_roles_and_departments(roles.pluck(:role_id), roles.pluck(:department_id)).general
  end

  def reviewable_users
    roles = task_list_roles.reviewable
    User.by_roles_and_departments(roles.pluck(:role_id), roles.pluck(:department_id)).general
  end

  def permission_to(user)
    role = user.current_property_role.id
    departments = user.departments.pluck(:id)

    reviewable = task_list_roles.reviewable.where(
        role_id: role,
        department_id: departments
    ).count > 0
    return 'review' if reviewable

    assignable = task_list_roles.assignable.where(
        role_id: role,
        department_id: departments
    ).count > 0
    return 'assign' if assignable

    'unknown'
  end

  def active?
    deleted_at.blank?
  end

  def start_resume!(user, params = {})
    record = task_list_records.started.find_or_initialize_by(user_id: user.id)

    if record.persisted? && params[:task_list_record_id].present? && record.id != params[:task_list_record_id]
      return false
    end

    started = record.persisted?

    unless started
      record.started_at = Time.current
      record.status = TaskListRecord.statuses[:started]
      record.save!

      task_items.categories.order(:id).each do |category|
        item_record = record.task_item_records.find_or_initialize_by(user_id: user.id, task_item_id: category.id)
        item_record.created_by = user
        item_record.save!

        category.items.order(:id).each do |item|
          item_record = record.task_item_records.find_or_initialize_by(user_id: user.id, task_item_id: item.id)
          item_record.created_by = user
          item_record.save!
        end
      end
    end

    record
  end

  def started_task_list_record(user)
    return if user.nil?
    self.task_list_records.where(user_id: user.id, status: 'started').first
  end
end
