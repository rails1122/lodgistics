class MessagesController < ApplicationController
  around_action :action_with_property, only: [:index]

  respond_to :json

  def index
    messagable = params[:model_type].classify.constantize.find(params[:model_id])
    @messages = messagable.messages
    @messages.build(
      user_id: messagable.closed_by_user_id,
      body: "(Closing Comment) #{messagable.closing_comment}",
      created_at: messagable.closed_at
    ) if messagable.is_a?(Maintenance::WorkOrder) && messagable.closed? && messagable.closing_comment.present?
    @messages = @messages.to_a.sort_by(&:created_at).reverse!
  end

  def create
    p = message_params
    @message = Message.new(body: p[:body], attachment: p[:attachment], messagable_type: p[:model_type], messagable_id: p[:model_id], user: current_user)
    if @message.save
      render action: 'show'
    else
      render json: {error: 'Failed to add message'}, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:model_id, :model_type, :property_id, :body, :attachment)
  end
end
