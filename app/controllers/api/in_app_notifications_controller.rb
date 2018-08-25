class Api::InAppNotificationsController < Api::BaseController
  #include InAppNotificationsDoc

  skip_before_action :set_resource

  def index
    @in_app_notifications = current_user.in_app_notifications
  end

  private

end
