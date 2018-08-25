class TaskListRole < ApplicationRecord
  include PropertyScopable

  belongs_to :task_list
  belongs_to :department
  belongs_to :role

  validates :department_id, :role_id, :property_id, presence: true

  enum scope_type: {
      assignable: 0,
      reviewable: 1
  }
end