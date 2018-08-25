class InAppNotificationsChannel < ApplicationCable::Channel
  def subscribed
    unless (current_user.try(:id) == params[:user_id])
      reject
      return
    end

    stream_from "in_app_notification_#{params[:user_id]}"
  end
end
