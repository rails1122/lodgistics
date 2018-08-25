class Maintenance::WorkOrdersController < Maintenance::BaseController
  before_action :authorize_work_order
  around_action :action_with_property, only: [:new, :create, :edit, :update]
  include SentientController

  def new
    @work_order = Maintenance::WorkOrder.new(status: :open, priority: :m, assigned_to_id: Maintenance::WorkOrder::UNASSIGNED, property_id: Property.current.try(:id))
    @work_order.build_checklist_item_maintenance
    @schedule = Schedule.new
    2.times { @work_order.attachments.build }
    render layout: false
  end

  def create
    @work_order = Maintenance::WorkOrder.new permitted_attributes
    @work_order.property_id = Property.current.try(:id)
    authorize @work_order

    @work_order.opened_at = Time.zone.now
    @work_order.opened_by = current_user
    @work_order.save

    @work_order = @work_order.get_schedule.generate_next_occurrence if @work_order.recurring?

    InAppNotificationService.new.new_work_order(@work_order)
    InAppNotificationService.new.assigned_work_order(@work_order)

    render partial: 'work_order', locals: { work_order: @work_order }
  end

  def edit
    @work_order = Maintenance::WorkOrder.find params[:id]
    @schedule = @work_order.get_schedule
    unless policy(@work_order).edit?
      render nothing: true, status: :unauthorized
      return
    end
    (2 - @work_order.attachments.count).times { @work_order.attachments.build }
    render layout: false
  end

  def update
    @work_order = Maintenance::WorkOrder.unscoped.find params[:id]
    authorize @work_order
    old_status = @work_order.status
    @work_order.update(permitted_attributes)
    new_status = @work_order.status

    if (old_status != new_status && new_status === 'closed')
      feed_post = @work_order.status_update_feed_post
      if (feed_post.present?)
        feed_post.save!
      end

      chat_message = @work_order.status_update_chat_message
      if chat_message.present? && current_user.push_notification_setting&.enabled?
        chat_message.save!
        chat_message_json = ChatMessageSerializer.new(chat_message, current_user: current_user).as_json
        h = chat_message_json.merge(work_order: SimplifiedWorkOrderSerializer.new(@work_order).as_json)
        ActionCable.server.broadcast "chat_id_#{chat_message.chat_id}", h
      end

      WorkOrderNotificationService.new(@work_order.id).execute_complete
    end

    old_assigned_user_id = @work_order.assigned_to_id
    if (old_assigned_user_id != @work_order.assigned_to_id)
      InAppNotificationService.new.assigned_work_order(@work_order)
    end

    @work_order = @work_order.get_schedule.generate_next_occurrence if @work_order.require_next_occurrence?
    if !scoped_work_orders.map(&:id).include?(@work_order.try(:id))
      head 200
    else
      if request.format.json?
        render json: @work_order
      else
        render partial: 'work_order', locals: { work_order: @work_order }
      end
    end
  end

  def destroy
    @work_order = Maintenance::WorkOrder.find params[:id]
    authorize @work_order
    if @work_order.destroy
      render json: @work_order.id
    else
      render json: {error: 'Failed to delete Equipment Type'}, status: 422
    end
  end

  def index
    authorize Maintenance::WorkOrder
    @filter = params[:filter] || {status: 'active'}
    @current_properties = current_properties
    @users = [{id: current_user.id, name: 'My WOs'}] + [{id: Maintenance::WorkOrder::UNASSIGNED, name: Maintenance::WorkOrder::UNASSIGNED_NAME}] +
      [{id: Maintenance::WorkOrder::THIRD_PARTY, name: Maintenance::WorkOrder::THIRD_PARTY_NAME}] +
      scoped_users.map { |u| {id: u.id, name: u.name_with_status} }
    @closed_users = @users.select { |u| !Maintenance::WorkOrder::EXTRA_IDS.include?(u[:id]) }

    respond_to do |format|
      format.html
      format.js do
        @work_orders = scoped_work_orders(@filter)
      end
    end
  end

  def export
    authorize Maintenance::WorkOrder
    filename = "#{Property.current.name}_#{I18n.l(Date.today, format: :mini)}_active work orders_#{I18n.l(Time.current, format: :short_time)}.csv"
    respond_to do |format|
      format.csv do
        send_data Maintenance::WorkOrder.to_csv({group_by: current_user.work_order_group_by}), filename: filename
      end
    end
  end

  private

  def permitted_attributes
    @work_order ||= Maintenance::WorkOrder.new
    params.require(:maintenance_work_order).permit(policy(@work_order).permitted_attributes)
  end

  def current_properties
    current_user.corporate? ? current_user.all_properties : [Property.current]
  end

  def scoped_work_orders(filter = {})
    @work_orders = []
    @includes ||= [
      {checklist_item_maintenance: [:maintenance_checklist_item, :maintenance_record]},
      :opened_by, :assigned_to, :occurrence
    ]
      if current_user.corporate?
        current_properties.each do |p|
          p.run_block_with_no_property do
            @work_orders += Pundit.policy_scope!(current_user, Maintenance::WorkOrder)
                              .by_filter(filter)
                              .order(id: :desc)
                              .includes(@includes).to_a
          end
        end
      else
        @work_orders = policy_scope(Maintenance::WorkOrder)
                         .by_filter(filter)
                         .where(property_id: Property.current_id, deleted_at: nil, recurring: false)
                         .order(id: :desc)
                         .includes(@includes).to_a
      end
    @work_orders
  end

  def scoped_users
    users = []
    if current_user.corporate?
      current_user.all_properties.find_each do |p|
        p.run_block_with_no_property do
          users += User.where(id: p.user_roles.with_deleted.where.not(user_id: current_user.id).pluck(:user_id)).to_a
        end
      end
    else
      users = User.where(id: Property.current.user_roles.with_deleted.where.not(user_id: current_user.id).pluck(:user_id)).to_a
    end
    users.uniq.sort_by &:name
  end
end
