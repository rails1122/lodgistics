class TaskItem < ApplicationRecord
  include PropertyScopable
  include RankedModel

  ranks :category_row_order, scope: :categories, column: :row_order
  ranks :item_row_order, with_same: :category_id, scope: :active, column: :row_order

  belongs_to :task_list
  belongs_to :category, class_name: 'TaskItem', foreign_key: :category_id, inverse_of: :items
  has_many :items, -> { rank(:item_row_order).active }, class_name: 'TaskItem', foreign_key: :category_id

  mount_uploader :image, TaskItemImageUploader

  validates :title, :task_list_id, presence: true

  scope :active, -> { where(deleted_at: nil) }
  scope :inactive, -> { where.not(deleted_at: nil) }
  scope :categories, -> { where(category_id: nil) }

  def active?
    deleted_at.blank?
  end

  def category?
    category_id.nil?
  end
end