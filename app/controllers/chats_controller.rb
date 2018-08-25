class ChatsController < ApplicationController
  authorize_resource
  load_resource only: [ :show ]

  def index
    @chats = current_user.chats.for_property_id(Property.current_id)
  end

  def show
    page = params[:page] || 1
    @chats = current_user.chats.for_property_id(Property.current_id)
    @chat_messages = @chat.chat_messages.order('id desc').page(page).reverse
    respond_to do |format|
      format.html
      format.json { render json: @chat_messages }
    end
  end

  def new
    @users = Property.current.try(:users) || []
    @chat = Chat.new(is_private: params[:is_private])

    if (params[:is_private])
      already_created_private_chats = Chat.private_chats_only.for_property_id(Property.current_id).select { |i| i.users.map(&:id).include?(current_user.id) }
      l = already_created_private_chats.map(&:users).flatten.uniq
      @users = @users - l
    end
  end

  def create
    p = chat_params.merge(created_by_id: current_user.id, user_id: current_user.id, property_id: Property.current_id)
    user_ids = p[:user_ids] || []
    user_ids.push(current_user.id)
    user_ids = user_ids.uniq
    p[:user_ids] = user_ids

    @chat = Chat.new(p)
    if @chat.is_private && @chat.is_duplicate_private_chat?
      @chat = Chat.find_duplicate_private_chat(@chat)
      render json: @chat, status: 200
      return
    end

    @chat.save!
    @chat.save_default_image_url if p[:image_url].blank?
    service = ChatNotificationService.new(chat: @chat, current_user: current_user)
    service.send_notifications

    respond_to do |format|
      format.html
      format.json { render json: @chat, stauts: 200 }
    end
  end

  private

  def chat_params
    params.require(:chat).permit(
      :name, :image, :created_by_id, :user_id, :property_id, :is_private, user_ids: []
    )
  end

end

