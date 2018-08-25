class Maintenance::WorkOrder < ApplicationRecord
  include Rails.application.routes.url_helpers
  include PublicActivity::Common
  include ::StampUser

  has_paper_trail :only => [:status]
  acts_as_paranoid

  STATUSES = [STATUS_OPEN=:open, STATUS_CLOSED=:closed, STATUS_WORKING=:working]
  MAINTEINABLE_TYPES = %w(Maintenance::Room Maintenance::PublicArea Maintenance::Equipment)
  PRIORITIES = %w(high medium low) # h => high, m => medium, l => low

  EXTRA_USERS = [
    [THIRD_PARTY_NAME = '3rd Party', THIRD_PARTY = -1],
    [UNASSIGNED_NAME = 'Unassigned', UNASSIGNED = -2]
  ]
  EXTRA_IDS = [THIRD_PARTY, UNASSIGNED]

  belongs_to :property
  belongs_to :maintainable, polymorphic: true
  belongs_to :checklist_item_maintenance, foreign_key: :checklist_item_maintenance_id, class_name: 'Maintenance::ChecklistItemMaintenance'
  belongs_to :opened_by, foreign_key: :opened_by_user_id, class_name: 'User'
  belongs_to :closed_by, foreign_key: :closed_by_user_id, class_name: 'User'
  belongs_to :updator, foreign_key: :updated_by, class_name: 'User'
  belongs_to :assigned_to, class_name: 'User'
  has_many :attachments, class_name: 'Maintenance::Attachment', as: :attachmentable
  has_many :messages, as: :messagable
  has_many :materials, class_name: 'Maintenance::Material', foreign_key: :work_order_id
  has_many :material_items, class_name: 'Item', through: :materials, source: :item
  has_one :schedule, -> { active }, as: :eventable
  has_many :occurrences, through: :schedule
  has_many :past_schedules, -> { deleted }, class_name: 'Schedule', as: :eventable
  has_many :past_occurrences, through: :past_schedules, class_name: 'Occurrence', source: :occurrences
  has_one :occurrence, as: :eventable

  scope :opened, -> { where(status: STATUS_OPEN) }
  scope :closed, -> { where(status: STATUS_CLOSED) }
  scope :active, -> { where.not(status: STATUS_CLOSED) }
  scope :unassigned, -> { where(assigned_to_id: UNASSIGNED) }
  scope :by_assignee, -> (assigned_to) { where(assigned_to_id: assigned_to) }
  scope :with_recurring, -> { where(recurring: [true, false]) }

  accepts_nested_attributes_for :checklist_item_maintenance
  accepts_nested_attributes_for :attachments, :allow_destroy => true

  attr_accessor :maintenance_checklist_item_id

  before_update :update_closed_at
  before_update :update_location_name
  before_save :set_default_values
  after_save :send_notification_and_mail_to_assignee
  after_save :create_wo_activity

  def self.default_scope
    where(property_id: Property.current_id, deleted_at: nil, recurring: false)
  end

  def self.by_priority
    ret = 'CASE'
    PRIORITIES.map { |p| p[0] }.each_with_index do |p, i|
      ret << " WHEN priority = '#{p}' THEN #{i}"
    end
    ret << ' END'
  end
  scope :order_by_priority, -> { order(by_priority) }
  scope :order_by_wo_type, -> { order('checklist_item_maintenance_id DESC NULLS LAST') }
  scope :order_by_status, -> { order("CASE WHEN status = '#{STATUS_OPEN}' THEN 0 WHEN status = '#{STATUS_WORKING}' THEN 1 END") }
  scope :order_by_assigned_to, -> {
    joins('LEFT JOIN users ON maintenance_work_orders.assigned_to_id = users.id')
      .order('maintenance_work_orders.assigned_to_id ASC').order('users.name ASC')
  }
  scope :order_by_created_by, -> {
    joins('LEFT JOIN users ON maintenance_work_orders.opened_by_user_id = users.id').order('users.name ASC')
  }

  scope :for_property_id, -> (given_property_id) { where(property_id: given_property_id) }

  def self.by_departments(departments, sql = nil)
    user_ids = DepartmentsUser.where(department_id: departments).pluck(:user_id)
    all.where(
      "assigned_to_id in (?) or opened_by_user_id in (?) #{'OR ' + sql if sql}", user_ids, user_ids
    )
  end

  def self.by_filter(filter)
    records = all
    records = records.send filter[:status] if filter[:status]
    records = records.where(
      closed_at: Date.parse(filter[:from]).beginning_of_day..Date.parse(filter[:to]).end_of_day
    ) if filter[:from] && filter[:to]
    records = records.where(maintainable_type: filter[:wo_type]) if filter[:wo_type]
    records
  end

  def schedule_id=(schedule_id)
    unless schedule_id.blank?
      schedule = Schedule.find schedule_id
      schedule.eventable = self
      schedule.save

      self.update(recurring: true)
    end
  end

  def self.to_csv(options = {})
    group_by = options.delete :group_by

    work_orders = Maintenance::WorkOrder.where.not(status: STATUS_CLOSED).includes(:assigned_to, :property, :opened_by)
    work_orders = work_orders.send "order_by_#{group_by}"
    headers = [
      'Hotel Name', 'Work Order Number', 'Description', 'Priority', 'Status', 'Assigned To',
      'Due Date', 'Created By', 'Created At', '# of Days Open'
    ]

    CSV.generate(options) do |csv|
      csv << headers
      work_orders.each do |wo|
        assigned_name = if wo.assigned_to_id == THIRD_PARTY
                          THIRD_PARTY_NAME
                        elsif wo.assigned_to_id == UNASSIGNED
                          UNASSIGNED_NAME
                        else
                          wo.assigned_to.try :name
                        end
        data = []
        data << wo.property.name << "##{wo.id}" << wo.description
        data << I18n.t("maintenance.work_orders.index.priorities.#{wo.priority}")
        data << wo.status.humanize << assigned_name << (wo.due_to_date ? I18n.l(wo.due_to_date, format: :mini) : '')
        data << wo.opened_by.try(:name) << (wo.created_at ? I18n.l(wo.created_at, format: :date_and_am_pm) : '') << wo.days_opened
        csv << data
      end
    end
  end

  def closed?
    status == STATUS_CLOSED.to_s
  end

  def close_by(u, options = {})
    options.reverse_merge!(should_send_notification: true)
    self.status = STATUS_CLOSED
    self.updated_by = u.try(:id)
    self.save
    self.closed_by_user_id = u.try(:id)
    self.save
    if options[:should_send_notification]
      WorkOrderNotificationService.new(self.id).execute_complete
    end
  end

  def recurring?
    self.recurring || (occurrence && occurrence.schedule.eventable.recurring?)
  end

  def require_next_occurrence?
    return false unless recurring?
    (get_schedule && get_schedule.occurrences.count == 0) ||
        (self.closed? && self.occurrence.present? && self.occurrence.eventable.recurring?)
  end

  def get_schedule
    recurring? ? schedule || occurrence.schedule.eventable.schedule : self.build_schedule
  end

  def number
    occurrence.nil? ? "##{id}" : occurrence.number
  end

  def trending_id
    occurrence.nil? ? self.id : occurrence.schedule.eventable_id
  end

  def days_opened
    (Date.current - opened_at.to_date).to_i + 1
  end

  def days_elapsed
    (closed_at.to_date - opened_at.to_date).to_i + 1 if closed? && closed_at && opened_at
  end

  def checklist_item_name
    if maintainable_type == 'Maintenance::Equipment'
      maintainable.try(:equipment_type).try(:name)
    else
      checklist_item_maintenance.try(:maintenance_checklist_item).try(:name)
    end
  end

  def set_location_name
    self.update(location_name: get_location_name)
  end

  def get_location_name
    maintainable_id.present? && maintainable.to_s + ( checklist_item_name ? " | #{checklist_item_name}" : '') || other_maintainable_location
  end

  def location_detail
    maintainable_detail = if maintainable_id.present?
                            if maintainable.is_a? Maintenance::Room
                              maintainable_name
                            elsif maintainable.is_a? Maintenance::PublicArea
                              "Public Area '#{maintainable_name}'"
                            elsif maintainable.is_a? Maintenance::Equipment
                              "Equipment '#{maintainable_name}'"
                            end
                          else
                            other_maintainable_location
                          end
    [maintainable_detail, checklist_item_name].reject(&:blank?).join(" / ")
  end

  # returns:
  # { "Maintenance::Room" => { 1 => "101",  2 => "102" }, "Maintenance::PublicArea" => { 1 => "Conference Room A", 4 => "Gym" }}
  def self.maintenable_entities
    Maintenance::WorkOrder::MAINTEINABLE_TYPES.inject({}) do |hash, mt|
      hash[mt] = mt.constantize.all.inject({}){ |mt_hash, mt_record| mt_hash[mt_record.id]= mt_record.name; mt_hash }
      hash
    end
  end

  def maintainable_name
    maintainable_id.present? ? maintainable.to_s : other_maintainable_location
  end

  def assigned_to_name
    if assigned_to_id > 0
      assigned_to.name
    else
      assigned_to_id == THIRD_PARTY ? THIRD_PARTY_NAME :
        assigned_to_id == UNASSIGNED ? UNASSIGNED_NAME : ''
    end
  end

  def due_to_date=(val)
    if val =~ %r{\A(\d+)/(\d+)/(\d{4})\z} # "09/29/2017"
      write_attribute(:due_to_date, Date.new($3.to_i, $1.to_i, $2.to_i))
    else
      if val.empty?
        write_attribute(:due_to_date, nil)
      else
        write_attribute(:due_to_date, Date.parse(val))
      end
    end
  end

  def pm_work_order?
    checklist_item_maintenance && checklist_item_maintenance.maintenance_record
  end

  def sub_category
    case maintainable_type
    when 'Maintenance::Room'
      checklist_item_name
    when 'Maintenance::PublicArea'
      maintainable.name
    when 'Maintenance::Equipment'
      maintainable.equipment_type.name
    end
  end

  def messages_count
    messages.count + (closed? && closing_comment.present? ? 1 : 0)
  end

  def material_total
    materials.map(&:cost).reduce(&:+)
  end

  def resource_url
    "#{maintenance_work_orders_url(host: Settings.host)}?id=#{id}"
  end

  def first_img_url
    first_attachment = self.attachments[0]
    if first_attachment.present? && first_attachment.file.file&.exists?
      return first_attachment.file.url
    end
    super
  end

  def second_img_url
    second_attachment = self.attachments[1]
    if second_attachment.present? && second_attachment.file.file&.exists?
      return second_attachment.file.url
    end
    super
  end

  def status_update_chat_message(message = 'Work order has been closed')
    chat = ChatMessage.find_by(work_order_id: self.id).try(:chat)
    return if chat.blank?
    sender = User.lodgistics_bot_user
    ChatMessage.new(chat_id: chat.id, message: message, sender_id: sender.id, property_id: chat.property_id, work_order_id: self.id)
  end

  def status_update_feed_post(message = 'Work order has been closed')
    feed = Engage::Message.find_by(work_order_id: self.id)
    return if feed.blank?
    sender = User.lodgistics_bot_user
    Engage::Message.new(title: message, body: message, created_by_id: sender.id, property_id: feed.property_id, parent_id: feed.id)
  end

  private

  def update_closed_at
    if status_changed? && closed?
      self.closed_at = Time.now
      self.closed_by = updator
    end
  end

  def update_location_name
    if maintainable_id_changed? || maintainable_type_changed?
      self.location_name = get_location_name
    end
  end

  def send_notification_and_mail_to_assignee
    if (assigned_to_id_changed?) && assigned_to
      Notification.assigned_work_order(self)
      WorkOrderNotificationService.new(id).execute_assigned
      begin
        MaintenanceWorkOrderMailer.work_order_notification_to_assignee(self).deliver!
      rescue => e
        Airbrake.notify(e)
        Rails.logger.error "Failed to send notification for work order - #{e.message}"
      end
      true
    end
  end

  def create_wo_activity
    if created_at_changed?
      create_activity key: 'work_order.created', recipient: Property.current, owner: opened_by
    elsif status_changed?
      case status
        when 'open'
          create_activity key: 'work_order.reopened', recipient: Property.current, owner: updator
        when 'closed'
          create_activity key: 'work_order.closed', recipient: Property.current, owner: updator
        when 'working'
          create_activity key: 'work_order.status_working', recipient: Property.current, owner: updator
      end
    end
    true
  end

  def set_default_values
    self.status ||= STATUS_OPEN.to_s
    self.assigned_to_id ||= UNASSIGNED
    self.priority ||= 'm'
    self.location_name = get_location_name
  end
end
