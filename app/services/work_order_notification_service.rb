class WorkOrderNotificationService
  def initialize(work_order_id)
    # TODO : without 'unscoped', find methond won't work. fuck default scope.
    @work_order = Maintenance::WorkOrder.unscoped.find(work_order_id)
  end

  def execute_assigned
    assigned = @work_order.assigned_to
    return unless assigned.push_notification_setting&.enabled?
    return unless assigned.push_notification_setting&.work_order_assigned_notification_enabled

    title = "WO #{@work_order.id} assigned to you in #{@work_order.property&.name}"
    if @work_order.priority == "h"
      title = "[High Priority] #{title}"
    end

    body = "[#{priority_label}] for #{@work_order.location_name}\n#{@work_order.description}"
    alert = NotificationHelper.generate_alert_for_apn(
      title: title,
      body: body
    )

    NotificationHelper.send_push_notification(assigned, alert, non_aps_attributes("wo_added"))
    NotificationHelper.send_push_notification_gcm(
      assigned,
      { title: title, body: body },
      non_aps_attributes("wo_added")
    )
  end

  def execute_complete
    creator = @work_order.opened_by
    return unless creator.push_notification_setting&.enabled?
    return unless creator.push_notification_setting&.work_order_assigned_notification_enabled

    title = "WO ##{@work_order.id} closed!"
    body = "#{@work_order.closed_by&.name} has completed work order for #{@work_order.location_name} "\
           "at #{@work_order.closed_at&.strftime("%H:%M")}\n#{@work_order.description}"
    alert = NotificationHelper.generate_alert_for_apn(
      title: title,
      body: body
    )
    NotificationHelper.send_push_notification(creator, alert, non_aps_attributes("wo_closed"))
    NotificationHelper.send_push_notification_gcm(
      creator,
      { title: title, body: body },
      non_aps_attributes("wo_completed")
    )
  end

  private

  def priority_label
    if @work_order.priority == "h"
      "High"
    elsif @work_order.priority == "m"
      "Medium"
    elsif @work_order.priority == "l"
      "Low"
    else
      ""
    end
  end

  def non_aps_attributes(status)
    {
      type: {
        name: status,
        property_token: @work_order.property.token,
        detail: {
          work_order_id: @work_order.id,
          work_order_url: @work_order.resource_url
        }
      }
    }
  end
end
