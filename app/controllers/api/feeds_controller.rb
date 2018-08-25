module Api
  class FeedsController < BaseController
    include FeedsDoc
    include SentientController

    skip_before_action :set_resource

    def show
      @feed = Engage::Message.for_property_id(Property.current_id).find(params[:id])
    end

    def index
      @feeds = ::Engage::Message.includes(:created_by).threads
      start_date = Date.today
      end_date = Date.today
      if params[:start_datetime].present? && params[:end_datetime].present?
        start_date = DateTime.parse(params[:start_datetime]).to_date
        end_date = DateTime.parse(params[:end_datetime]).to_date
        @feeds = @feeds.updated_between_datetimes(DateTime.parse(params[:start_datetime]), DateTime.parse(params[:end_datetime]))
      else
        start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
        end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
        @feeds = @feeds.updated_between_dates(start_date, end_date)
      end
      updated_after = params[:updated_after] && DateTime.parse(params[:updated_after])
      @feeds = @feeds.for_property_id(Property.current_id).updated_after(updated_after).reorder(updated_at: :desc).includes(:created_by, :completed_by).to_a

      @feeds_by_date = @feeds.group_by { |feed| feed.updated_at.to_date }

      @feeds.each do |feed|
        next unless feed.follow_up?
        start_date.upto(end_date) do |date|
          next unless date.between?(feed.follow_up_start, feed.follow_up_end)
          next if date == feed.created_at.to_date
          @feeds_by_date[date] ||= []
          @feeds_by_date[date].unshift(feed)
        end
      end

      @feeds = @feeds_by_date.values.flatten
    end

    def broadcasts
      date = parse_time(params[:date]).to_date
      @feeds = ::Engage::Message.for_property_id(Property.current_id)
                   .broadcast(date).includes(:created_by)
    end

    def follow_ups
      date = parse_time(params[:date]).to_date
      @feeds = ::Engage::Message.for_property_id(Property.current_id)
                   .follow_ups(date).includes(:created_by)
    end

    def create
      p = feed_params.merge(property_id: Property.current_id)
      @feed = current_user.engage_messages.build(p)
      @feed.save!

      @feed.create_mention_records(params[:feed][:mentioned_user_ids])
      @feed.parent.update(updated_at: DateTime.now) if (@feed.parent.present?)

      FeedNotificationService.new(feed: @feed, current_user: current_user).send_notifications
      InAppNotificationService.new.new_feed(@feed, current_user: current_user)

      render :create, status: 201
    end

    def update
      p = feed_params.merge(property_id: Property.current_id)
      @feed = Engage::Message.for_property_id(Property.current_id).find params[:id]
      @feed.update(p)

      render :show, status: :ok
    end

    private

    def feed_params
      params[:feed][:remote_image_url] = params[:feed][:image_url]
      params.require(:feed).permit(
          :title, :body, :parent_id, :complete,
          :remote_image_url, :image_width, :image_height,
          :broadcast_start, :broadcast_end,
          :follow_up_start, :follow_up_end
      )
    end
  end
end
