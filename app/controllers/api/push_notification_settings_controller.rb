class Api::PushNotificationSettingsController < Api::BaseController
  include PushNotificationSettingsDoc

  skip_before_action :set_resource

  def index
    @push_notification_setting = current_user.push_notification_setting
    render json: @push_notification_setting
  end

  def update
    @push_notification_setting = current_user.push_notification_setting
    @push_notification_setting.update(push_notification_setting_params)
    render json: @push_notification_setting
  end

  private

  def push_notification_setting_params
    permitted = [:enabled, :chat_message_notification_enabled,
                 :feed_post_notification_enabled, :acknowledged_notification_enabled,
                 :work_order_completed_notification_enabled, :work_order_assigned_notification_enabled,
                 :unread_mention_notification_enabled, :unread_message_notification_enabled,
                 :feed_broadcast_notification_enabled,
                 :all_new_messages, :all_new_log_posts ]
    params.require(:push_notification_setting).permit(permitted)
  end
end
