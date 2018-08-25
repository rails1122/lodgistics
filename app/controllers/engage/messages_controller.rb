class Engage::MessagesController < ApplicationController
  include SentientController

  around_action :property_time_zone
  before_action :get_date, only: [:index, :create, :update]
  before_action :get_message, only: [:update]

  def index
    @messages = Engage::Message.threads.occurred_on(@date).includes(:work_order, :created_by, :completed_by, replies: [:created_by])
    render json: @messages.for_property_id(Property.current_id).as_json(user: current_user, date: @date)
  end

  def create
    p = message_params.merge(property_id: Property.current_id)
    @message = current_user.engage_messages.build(p)
    if @message.save
      @message.create_mention_records(params[:message][:mentioned_user_ids])
      @message.parent.update(updated_at: DateTime.now) if (@message.parent.present?)

      FeedNotificationService.new(feed: @message, current_user: current_user).send_notifications
      InAppNotificationService.new.new_feed(@message, current_user: current_user)

      render json: @message.as_json(user: current_user, date: @date)
    else
      render json: @message.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

  def update
    if @message.update_attributes(message_params)
      render json: @message.as_json(user: current_user, date: @date)
    else
      render json: @message.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(
      :room_number, :title, :body, :parent_id, :follow_up_start, :follow_up_end,
      :broadcast_start, :broadcast_end, :like, :complete, :work_order_id, :image
    )
  end

  def get_message
    @message = Engage::Message.find params[:id]
  end

  def get_date
    @date = Date.parse(params[:date] || Date.today.to_s)
  end
end
