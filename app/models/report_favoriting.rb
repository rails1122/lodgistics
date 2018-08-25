class ReportFavoriting < ApplicationRecord
  belongs_to :report
  belongs_to :user
end
