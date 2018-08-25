module ChatMessageMethods
  extend ActiveSupport::Concern

  def create
    p = chat_message_params.merge(sender_id: current_user.id, property_id: Property.current_id)
    @chat_message = ChatMessage.new(p)
    @chat_message.save!

    mentioned_user_ids = (params[:chat_message][:mentioned_user_ids] || []).map(&:to_i)
    if (mentioned_user_ids.present?)
      @chat_message.create_mention_records(mentioned_user_ids)
    end

    service = ChatMessageNotificationService.new(current_user: current_user, chat_message: @chat_message)
    service.send_notifications

    InAppNotificationService.new.unread_message(@chat_message, current_user: current_user)

    h = ChatMessageSerializer.new(@chat_message, current_user: current_user).as_json
    ActionCable.server.broadcast "chat_id_#{@chat_message.chat_id}", h

    render json: h
  end

  private

  def chat_message_params
    params[:chat_message][:remote_image_url] = params[:chat_message][:image_url]
    params.require(:chat_message).permit(
      :message, :chat_id, :mentioned_user_ids, :remote_image_url, 
      :responding_to_chat_message_id
    )
  end

end
