class Schedule < ApplicationRecord
  WEEK = [['M', 1], ['T', 2], ['W', 3], ['T', 4], ['F', 5], ['S', 6], ['S', 0]]
  RECURRING_TYPES = [MONTHLY = 'monthly', WEEKLY = 'weekly']

  belongs_to :property
  belongs_to :eventable, -> { with_recurring }, polymorphic: true
  has_many :occurrences

  validates :start_date, :end_date, :interval, :recurring_type, :days, presence: true
  validates :recurring_type, inclusion: { in: RECURRING_TYPES }
  validate :valid_end_date

  default_scope { where(property_id: Property.current_id).includes(:occurrences) }
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  after_initialize :default_schedule
  after_create :enable_recurring
  after_save :disable_recurring
  before_destroy :clear_occurrences

  def start_date=(date)
    write_attribute :start_date, Date.strptime(date, "%m/%d/%Y")
  end

  def end_date=(date)
    write_attribute :end_date, Date.strptime(date, "%m/%d/%Y")
  end

  def active?
    self.deleted_at.nil?
  end

  def rule
    @rule = IceCube::Schedule.new(start_date, end_time: end_date) do |s|
      if recurring_type == WEEKLY
        s.add_recurrence_rule IceCube::Rule.weekly(interval).day(days).until(end_date)
      elsif recurring_type == MONTHLY
        s.add_recurrence_rule IceCube::Rule.monthly(interval).day_of_month(days).until(end_date)
      end
    end
  end

  def upcoming_dates
    dates = rule.all_occurrences.select { |date| date.to_date >= Date.today }.map(&:to_date)
    previous_dates = self.eventable.present? ? self.eventable.past_occurrences.pluck(:date) : []
    dates - previous_dates
  end

  def days
    read_attribute(:days).map(&:to_i)
  end

  def start_index
    past_count = self.eventable.past_occurrences.count if self.eventable
    (past_count || 0) + occurrences.past.count + 1
  end

  def generate_next_occurrence
    return nil if new_record?
    occurrences = self.occurrences.reload
    date = self.upcoming_dates.find do |d|
      o = occurrences.detect { |oo| oo.date == d }
      o.nil? || (o.status != Occurrence::STATUS_SKIP && o.status != Occurrence::STATUS_GENERATED)
    end

    return nil if date.nil? || eventable.nil?
    return nil if self.eventable.present? && (occurrences.upcoming.opened.count > 0 || self.eventable.past_occurrences.upcoming.opened.count > 0)

    o = occurrences.find_or_create_by(date: date)

    event = self.eventable.dup
    event.assigned_to_id = o.option.assigned_to_id if o.option.assigned_to_id
    event.due_to_date = I18n.l(o.date, format: :short)
    event.created_at = Time.current
    event.updated_at = Time.current
    event.opened_at = Time.current
    event.status = Maintenance::WorkOrder::STATUS_OPEN.to_s
    event.created_by = self.eventable.opened_by
    event.updated_by = self.eventable.opened_by
    event.recurring = false
    event.save

    o.status = Occurrence::STATUS_GENERATED
    o.eventable = event
    o.index = self.start_index + upcoming_dates.index(o.date)
    o.save

    event
  end

  # cron job to generate next 1 occurrence
  def self.generate_next_occurrences
    ActiveRecord::Base.transaction do
      Property.find_each do |p|
        p.run_block_with_no_property do        
          p.schedules.find_each do |s|
            s.destroy if s.eventable.nil?
            next unless s.active?
            s.generate_next_occurrence if s.occurrences.generated.last.date <= Date.today
          end
        end
      end
    end
  end

  private

  def valid_end_date
    errors.add(:end_date, 'Not valid end date') if start_date && end_date && start_date >= end_date
    errors.add(:base, 'No schedules') if upcoming_dates.count == 0
    true
  end

  def default_schedule
    self.start_date ||= I18n.l(Date.today, format: :short)
    self.end_date ||= I18n.l(1.days.from_now, format: :short)
    self.interval ||= 1
    self.recurring_type ||= WEEKLY
  end

  def enable_recurring
    eventable.update(recurring: true) if eventable
  end

  def disable_recurring
    eventable.update(recurring: false) if eventable && deleted_at.present?
  end

  def clear_occurrences
    occurrences.other.destroy_all
  end
end
