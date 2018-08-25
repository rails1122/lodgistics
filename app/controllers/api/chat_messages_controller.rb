class Api::ChatMessagesController < Api::BaseController
  include ChatMessagesDoc
  include ChatMessageMethods

  skip_before_action :set_resource

  rescue_from Errors::NotAuthorized, with: :render_unauthorized

  # NOTE : I think this api is very badly designed.
  # 1. parameter : giving 'id' parameter will filter by chat id.
  # so instead of 'id' it should use 'chat_id' to make it more clear
  # 2. response : I would probably return list and does group_by on the client side,
  # or I would create another end point that returns grouped_by results.
  def index
    list = current_user.chats.pluck :id

    options = filter_params
    options[:id] = filter_params[:id] == 'all' ? list : [filter_params[:id]]
    @messages = ChatMessage.filter options
    @messages = @messages.group_by(&:chat_id)
  end

  def updates
    chat_message_ids = params[:chat_message_ids]
    chat_message_ids = chat_message_ids.split(",") if params[:chat_message_ids].is_a?(String)
    @chat_messages = ChatMessage.where(id: chat_message_ids)
  end

  def mark_read
    @chat_message = ChatMessage.find(params[:id])
    @chat_message.read_by!(current_user)
  end

  def show
    @chat_message = ChatMessage.find(params[:id])
    @chat_message.check_if_user_can_read(current_user)
  end

  def mark_read_mass
    chat_message_ids = params[:chat_message_ids]
    chat_message_ids = chat_message_ids.split(",") if params[:chat_message_ids].is_a?(String)
    @chat_messages = ChatMessage.where(id: chat_message_ids)
    @chat_messages.each do |i|
      i.read_by!(current_user)
    end
  end

  private

  def filter_params
    params.permit(:from, :to, :type, :id, :last_id)
  end

end
