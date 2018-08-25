class DepartmentsTag < ApplicationRecord
  belongs_to :category
  belongs_to :department
end
