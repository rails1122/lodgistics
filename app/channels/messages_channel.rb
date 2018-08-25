class MessagesChannel < ApplicationCable::Channel
  def subscribed
    chat = Chat.find_by(id: params[:chat_id])
    if chat.blank? || !(chat.users.include?(current_user))
      reject
      return
    end

    stream_from "chat_id_#{params[:chat_id]}"
  end
end
