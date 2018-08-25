class Api::WorkOrdersController < Api::BaseController
  include WorkOrdersDoc

  before_action :set_feed, only: [ :create ]
  before_action :set_chat_message, only: [ :create ]

  def create
    p = work_order_params.merge(property_id: Property.current_id, opened_by_user_id: current_user.id)
    p[:maintainable_type] = "Maintenance::#{p[:maintainable_type]}".gsub(/\s+/, "") if ['Room', 'Equipment', 'PublicArea', 'Public Area'].include?(p[:maintainable_type])
    @work_order = Maintenance::WorkOrder.new(p)

    authorize @work_order

    @work_order.build_checklist_item_maintenance(maintenance_checklist_item_id: p[:maintenance_checklist_item_id])
    @work_order.opened_at = Time.zone.now
    @work_order.save!

    @feed.update(work_order_id: @work_order.id) if @feed
    @chat_message.update(work_order_id: @work_order.id) if @chat_message

    InAppNotificationService.new.new_work_order(@work_order)
    InAppNotificationService.new.assigned_work_order(@work_order)
  end

  def index
    authorize Maintenance::WorkOrder

    status = params[:status] || 'active'
    filter_param = { status: status }

    @work_orders = get_work_orders(filter_param)
  end

  def show
    @work_order = Maintenance::WorkOrder.unscoped.find(params[:id])
  end

  def update
    old_assigned_user_id = @work_order.assigned_to_id
    @work_order.update(work_order_update_params)
    if (old_assigned_user_id != @work_order.assigned_to_id)
      InAppNotificationService.new.assigned_work_order(@work_order)
    end
  end

  def close
    set_resource

    @work_order.close_by(current_user)
    work_order_json = WorkOrderSerializer.new(@work_order).as_json

    chat_message = @work_order.status_update_chat_message
    if chat_message.present?
      chat_message.save!
      chat_message_json = ChatMessageSerializer.new(chat_message, current_user: current_user).as_json
      work_order_json.merge!(chat_message: chat_message_json)
      h = chat_message_json.merge(work_order: SimplifiedWorkOrderSerializer.new(@work_order).as_json)
      ActionCable.server.broadcast "chat_id_#{chat_message.chat_id}", h
    end

    feed_post = @work_order.status_update_feed_post
    if feed_post.present?
      feed_post.save!
      feed_post.parent.update(updated_at: DateTime.now)
      feed_post_json = SimplifiedFeedSerializer.new(feed_post).as_json
      work_order_json.merge!(feed_post: feed_post_json)
    end

    WorkOrderNotificationService.new(@work_order.id).execute_complete

    render json: work_order_json
  end

  def assignable_users
    @assignable_users = Property.current.users.general.select { |u| u.wo_assignable_id > 0 }.map{ |u| [u.name.titleize, u.id] } + Maintenance::WorkOrder::EXTRA_USERS
    render json: @assignable_users.as_json
  end

  private

  def set_feed
    @feed = Engage::Message.find(params[:feed_id]) if (params[:feed_id])
  end

  def set_chat_message
    @chat_message = ChatMessage.find(params[:chat_message_id]) if (params[:chat_message_id])
  end

  # TODO : check and limit permitted parameters
  def work_order_update_params
    params.require(:work_order).permit(:description, :maintainable_id, :priority, :status, :due_to_date, :assigned_to_id, :first_img_url, :second_img_url, :maintenance_checklist_item_id)
  end

  def work_order_params
    params.require(:work_order).permit(:description, :maintainable_type, :other_maintainable_location, :maintainable_id, :priority, :status, :due_to_date, :assigned_to_id, :first_img_url, :second_img_url, :maintenance_checklist_item_id)
  end

  def get_work_orders(filter_param = {})
    if current_user.corporate?
      get_work_orders_for_corporate_user(filter_param)
    else
      get_work_orders_for_normal_user(filter_param)
    end
  end

  def get_work_orders_for_normal_user(filter_param)
    Pundit.policy_scope!(current_user, Maintenance::WorkOrder)
      .by_filter(filter_param)
      .where(property_id: Property.current_id, deleted_at: nil, recurring: false)
      .order(id: :desc)
      .includes(include_columns).to_a
  end

  def get_work_orders_for_corporate_user(filter_param)
    l = []
    properties = current_user.all_properties
    properties.each do |p|
      p.run_block_with_no_property do
        l += Pundit.policy_scope!(current_user, Maintenance::WorkOrder)
          .by_filter(filter_param)
          .order(id: :desc)
          .includes(include_columns).to_a
      end
    end
    l
  end

  def resource_class
    Maintenance::WorkOrder
  end

  def include_columns
    [
      {checklist_item_maintenance: [:maintenance_checklist_item, :maintenance_record]},
      :opened_by, :assigned_to, :occurrence
    ]
  end
end
