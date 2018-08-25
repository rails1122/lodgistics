class WeeklyReport
  def initialize(property)
    @property = property
  end

  def get_data
    @property.run do
      data = { current: {}, previous: {} }
      data[:name] = @property.name

      ##
      # +group_by_week(:xxx, last: N).count+ will return a hash
      # of last N weeks of items grouped by :xxx.
      #
      # Example:
      #   Maintenance::WorkOrder.closed.group_by_week(:created_at, last: 3).count
      #   => {Mon, 25 Jun 2018=>3, Mon, 02 Jul 2018=>8, Mon, 09 Jul 2018=>3}
      #
      # So, the last returned key corresponds to current running week.
      ##

      this_week_start  = Date.today.beginning_of_week(:monday)
      date_current     = this_week_start - 1.week
      date_previous    = date_current - 1.week


      # Displayed values in Report. Corresponds to :starts_of_week: (i.e. Mondays)
      #
      data[:current][:date]  = this_week_start
      data[:previous][:date] = date_current

      data[:current][:work_orders] = {
        new:    Maintenance::WorkOrder.group_by_week(:created_at, last: 3).count[date_current],
        opened: Maintenance::WorkOrder.active.count,
        closed: Maintenance::WorkOrder.closed.group_by_week(:closed_at, last: 3).count[date_current]
      }
      data[:previous][:work_orders] = {
        new:    Maintenance::WorkOrder.group_by_week(:created_at, last: 3).count[date_previous],
        opened: (data[:current][:work_orders][:opened] - Maintenance::WorkOrder.group_by_week(:created_at, last: 3).count[date_previous] + Maintenance::WorkOrder.closed.group_by_week(:closed_at, last: 3).count[date_previous]),
        closed: Maintenance::WorkOrder.closed.group_by_week(:closed_at, last: 3).count[date_previous]
      }

      data[:current][:checklists] = {
        completed: TaskListRecord.not_started.group_by_week(:finished_at, last: 3).count[date_current],
        reviewed:  TaskListRecord.reviewed.group_by_week(:reviewed_at, last: 3).count[date_current]
      }
      data[:previous][:checklists] = {
        completed: TaskListRecord.not_started.group_by_week(:finished_at, last: 3).count[date_previous],
        reviewed:  TaskListRecord.reviewed.group_by_week(:reviewed_at, last: 3).count[date_previous]
      }

      data[:current][:guest_logs] =  Engage::Message.for_property_id(@property.id).threads.group_by_week(:created_at, last: 3).count[date_current]
      data[:previous][:guest_logs] = Engage::Message.for_property_id(@property.id).threads.group_by_week(:created_at, last: 3).count[date_previous]

      data[:current][:chats] =  ChatMessage.where(property_id: @property.id).group_by_week('chat_messages.created_at', last: 3).count[date_current]
      data[:previous][:chats] = ChatMessage.where(property_id: @property.id).group_by_week('chat_messages.created_at', last: 3).count[date_previous]
#        direct: ChatMessage.where(property_id: @property.id).group_by_week('chat_messages.created_at', last: 3)
#                           .joins(:chat).where(chats: {is_private: true}).count[date_previous],
#        group: ChatMessage.where(property_id: @property.id).group_by_week('chat_messages.created_at', last: 3)
#                           .joins(:chat).where.not(chats: {is_private: true}).count[date_previous]

      return data
    end
  end

  def self.run!
    Property.where(name: WeeklyReport.property_list).each do |p|
      p.run do
        users = User.joins(:roles)
            .where(roles: {id: [Role.gm, Role.agm]}, user_roles: {property_id: p.id})
            .active

        report_data = WeeklyReport.new(p).get_data

        users.each do |user|
          next if user.email.blank?

          Mailer.weekly_report(report_data, user.id).deliver
        end
      end
    end
  end

  def self.property_list
    [
      "DoubleTree by Hilton Raleigh-Cary",
      "Hilton Garden Inn Raleigh-Cary",
      "Hyatt Place Asheville",
      "Aloft – Cool Springs",
      "Hampton Inn and Suites Burlington",
      "Tru by Hilton Raleigh-Durham",
      "Montford Rooftop Bar - HP Asheville",
      "Homewood Suites Cary",
      "SpringHill Suites – Wilmington"
    ]
  end
end
