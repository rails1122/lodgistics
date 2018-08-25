class Api::ChatsController < Api::BaseController
  include ChatsDoc

  skip_before_action :set_resource

  def index
    @privates = current_user.chats.private_chats_only.for_property_id(Property.current_id)
    @groups = current_user.chats.group_chats_only.for_property_id(Property.current_id)

    if params[:chat_id].present?
      if params[:is_private]
        @privates = @privates.where(id: params[:chat_id])
      else
        @groups = @groups.where(id: params[:chat_id])
      end
    end

    @groups = @groups.order(last_message_at: :desc, id: :desc)
    @privates = @privates.order(last_message_at: :desc, id: :desc)
  end

  def group_only
    if params[:chat_id].present?
      @chats = current_user.chats.group_chats_only.for_property_id(Property.current_id).where(id: params[:chat_id])
    else
      @chats = current_user.chats.group_chats_only.for_property_id(Property.current_id)
    end
    @chats = @chats.order('coalesce(chats.last_message_at, chats.created_at) desc')
  end

  def private_only
    @chats = current_user.chats.private_chats_only.for_property_id(Property.current_id)

    if params[:chat_id].present?
      @chats = @chats.where(id: params[:chat_id])
    else
      @chats = @chats.order('coalesce(chats.last_message_at, chats.created_at) desc')
      
      user_ids_already_in_chat = @chats.map(&:user_ids).flatten.uniq
      property_user_ids = Property.current.users.active.pluck :id
      user_ids_not_in_chat = property_user_ids - user_ids_already_in_chat - [ current_user.id ]

      # create and add empty private chat objects
      l = user_ids_not_in_chat.map do |uid|
        #:name, :image_url, :created_by_id, :user_id, :property_id, :is_private, user_ids: []
        Chat.new(user_ids: [uid, current_user.id], is_private: true, property_id: Property.current_id, user_id: current_user.id, created_by_id: current_user.id)
      end
      @chats += l.sort_by{ |chat| chat.target_user(current_user).name }
    end
  end

  def messages
    chat = Chat.find(params[:id])
    @messages = chat.chat_messages
    filter_by_message_id
    filter_by_date
    @messages = @messages.order(id: :desc)
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
      render :create, status: 201
      return
    end

    @chat.save!
    @chat.save_default_image_url if p[:image_url].blank?
    service = ChatNotificationService.new(chat: @chat, current_user: current_user)
    service.send_notifications

    render :create, status: 201
  end

  def update
    @chat = Chat.find(params[:id])
    p = @chat.is_private ? private_chat_update_params : chat_update_params
    @chat.update!(p)
    render :update
  end

  private

  def chat_params
    params[:chat][:remote_image_url] = params[:chat][:image_url] if params[:chat]
    params.require(:chat).permit(
      :name, :remote_image_url, :created_by_id, :user_id, :property_id, :is_private, user_ids: []
    )
  end

  def chat_update_params
    params[:chat][:remote_image_url] = params[:chat][:image_url]
    params.require(:chat).permit(
      :name, :remote_image_url, user_ids: []
    )
  end

  def private_chat_update_params
    params[:chat][:remote_image_url] = params[:chat][:image_url]
    params.require(:chat).permit(
      :name, :remote_image_url
    )
  end

  def filter_by_message_id
    @messages = @messages.where('id > ?', params[:message_id]) if params[:message_id]
  end

  def filter_by_date
    return unless params[:start_date]

    start_date = Date.parse(params[:start_date]).beginning_of_day
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]).end_of_day : DateTime.now.end_of_day
    @messages = @messages.created_between(start_date, end_date)
  end
end
