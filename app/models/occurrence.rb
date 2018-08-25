class Occurrence < ApplicationRecord
  serialize :option, OccurrenceOption

  acts_as_paranoid
  
  belongs_to :eventable, polymorphic: true, dependent: :destroy
  belongs_to :work_order, -> { where(occurrences: {eventable_type: 'Maintenance::WorkOrder'}) }, class_name: 'Maintenance::WorkOrder', foreign_key: :eventable_id
  belongs_to :schedule

  scope :upcoming, -> { where("date >= ?", Date.today) }
  scope :past, -> { where("date < ?", Date.today) }
  scope :generated, -> { where(status: STATUS_GENERATED).order(:date) }
  scope :opened, -> { joins(:work_order).where(maintenance_work_orders: {status: Maintenance::WorkOrder::STATUS_OPEN.to_s}) }
  scope :skipped, -> { where(status: STATUS_SKIP).order(:date) }
  scope :active, -> { where(status: STATUSES) }
  scope :other, -> { where.not(status: STATUS_GENERATED) }

  default_scope { order(:index) }

  STATUSES = [STATUS_SKIP = 'skip', STATUS_GENERATED = 'generated']

  validates :date, presence: true

  def number
    "##{schedule.try(:eventable_id)} (#{index})"
  end
end
