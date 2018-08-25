class TaskListRecordNotificationService
  def initialize(params)
    @task_list_record = params[:task_list_record]
    @current_user = params[:current_user]
  end

  def send_notifications
    # find reviwer for this task_list_record
    body = get_content
    title = get_title
    alert = NotificationHelper.generate_alert_for_apn(body: body, title: title)
    @task_list_record.task_list.reviewable_users.each do |notified_user |
      NotificationHelper.send_push_notification(notified_user, alert, non_aps_attributes)
      NotificationHelper.send_push_notification_gcm(notified_user, { body: body, title: title }, additional_gcm_attributes)
    end

    @task_list_record.update!(review_notified_at: Time.current)
  end

  def get_title
    "#{@task_list_record.task_list.name} completed"
  end

  def get_content
    "#{@task_list_record.finished_by.name} has completed the checklist and it is available for your review"
  end

  private

  attr_reader :feed, :current_user

  def non_aps_attributes
    {
      type: {
        name: 'task_list_record',
        property_token: @task_list_record.property&.token,
        detail: { task_list_record_id: @task_list_record.id, status: @task_list_record.status }
      }
    }
  end

  def additional_gcm_attributes
    non_aps_attributes
  end

end
