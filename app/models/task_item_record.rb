class TaskItemRecord < ApplicationRecord
  include PropertyScopable

  belongs_to :user
  belongs_to :task_list_record
  belongs_to :task_item
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by_id

  delegate :title, :category?, to: :task_item

  scope :incomplete, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :category_records, -> { joins(:task_item).where(task_items: {category_id: nil}) }
  scope :items, -> { joins(:task_item).where.not(task_items: {category_id: nil}) }

  def category_record
    if category?
      nil
    else
      task_list_record.task_item_records.find_by task_item_id: task_item.category_id
    end
  end

  def item_records
    if category?
      task_list_record.task_item_records
          .joins(:task_item)
          .where(task_items: {category_id: task_item.id})
          .includes(:user, :created_by, :updated_by)
          .order(:id)
    else
      TaskItemRecord.none
    end
  end

  def completed?
    if category?
      item_records.incomplete.count == 0
    else
      completed_at.present?
    end
  end

  def complete!(user, params = {})
    update_params = {
        updated_by_id: user.id
    }

    update_params[:completed_at] = Time.current if params[:status] == 'completed'
    update_params[:comment] = params[:comment] if params[:comment].present?

    self.update!(update_params)

    if category?
      item_records.update_all(update_params) if item_records.incomplete.count != 0
    else
      if category_record.item_records.incomplete.count == 0
        category_record.complete!(user, params)
      end
    end
  end

  def reset!(user, update_items = true)
    self.updated_by = user
    self.completed_at = nil
    self.save!

    if category?
      item_records.update_all(
          updated_by_id: user.id,
          completed_at: nil,
      ) if update_items
    else
      if category_record.item_records.incomplete.count > 0
        category_record.reset!(user, false)
      end
    end
  end
end