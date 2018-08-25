class Api::NotificationsController < Api::BaseController
  #include NotificationsDoc

  skip_before_action :set_resource

  def index
    @notifications = []
    render json: @notifications
  end

  private

end
