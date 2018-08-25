module Api::WorkOrdersDoc
  extend BaseDoc

  namespace 'api'
  resource :work_orders

  doc_for :index do
    api :GET, '/work_orders', 'Get work orders opened by current user'
    error 401, 'Unauthorized'
    error 500, "Server Error"

    param :status, String, desc: 'status - active, closed, opened'

    description <<-EOS
      If successful, it returns a json containing <tt>a list of work_order object</tt> opened by current user, sorted by created_at.

      WorkOrder object contains:
        id: id of work_order
        property_id: property_id of this work_order
        description: content/description
        priority: priority
        status: status
        due_to_date: due date
        assigned_to_id: user_id of this work_order is assigned to
        maintainable_type: maintainable_type
        other_maintainable_location: other maintainable location
        maintainable_id: maintainable_id
        opened_by_user_id: user_id who opened this work_order
        created_at: created_at
        updated_at: updated_at
        closed_by_user_id: user who closed this work order
        first_img_url: first img url
        second_img_url: second img url
        work_order_url: url to work order
        closed_at: datetime when closed
        closed: true if status is closed
        opened_at: datetime when this work order was opened
    EOS
  end

  doc_for :show do
    api :GET, '/work_orders/:id', 'Get work order detail'
    error 401, 'Unauthorized'
    error 500, "Server Error"
    error 404, "Not Found"

    description <<-EOS
      If successful, it returns a json containing <tt>work_order object</tt>

      WorkOrder object contains:
        id: id of work_order
        property_id: property_id of this work_order
        description: content/description
        priority: priority
        status: status
        due_to_date: due date
        assigned_to_id: user_id of this work_order is assigned to
        maintainable_type: maintainable_type
        other_maintainable_location: other maintainable location
        maintainable_id: maintainable_id
        opened_by_user_id: user_id who opened this work_order
        created_at: created_at
        updated_at: updated_at
        closed_by_user_id: user who closed this work order
        first_img_url: first img url
        second_img_url: second img url
        work_order_url: url to work order
        closed_at: datetime when closed
        closed: true if status is closed
        opened_at: datetime when this work order was opened
    EOS
  end


  doc_for :create do
    api :POST, '/work_orders', 'Create work order'
    error 401, 'Unauthorized'
    error 422, "Unable to create entity (e.g. validation failed)"
    error 500, "Server Error"
    param :work_order, Hash, desc: 'work order parameter', required: true do
      param :description, String, desc: 'description'
      param :priority, String, desc: 'priority - l, m, h'
      param :status, String, desc: 'status - open, closed, working'
      param :due_to_date, String, desc: 'due date - yyyy-mm-dd'
      param :assigned_to_id, Integer, desc: 'user id whom this work order is assigned to'
      param :maintainable_type, String, desc: "Type of maintainable - e.g. 'Room', 'Other', 'Equipment', 'PublicArea'"
      param :other_maintainable_location, String, desc: "maintainable location for 'Other' maintainable type"
      param :maintainable_id, Integer, desc: 'maintainable id'
      param :maintenance_checklist_item_id, Integer, desc: 'checklist item id'
      param :first_img_url, String, desc: 'img url for 1st img'
      param :second_img_url, String, desc: 'img url for 2nd img'
    end
    description <<-EOS
      If successful, it returns a json containing <tt>work_order object</tt>

      WorkOrder object contains:
        id: id of work_order
        property_id: property_id of this work_order
        description: content/description
        priority: priority
        status: status
        due_to_date: due date
        assigned_to_id: user_id of this work_order is assigned to
        maintainable_type: maintainable_type
        other_maintainable_location: other maintainable location
        maintainable_id: maintainable_id
        opened_by_user_id: user_id who opened this work_order
        created_at: created_at
        updated_at: updated_at
        closed_by_user_id: user who closed this work order
        first_img_url: first img url
        second_img_url: second img url
        work_order_url: url to work order
        closed_at: datetime when closed
        closed: true if status is closed
        opened_at: datetime when this work order was opened
    EOS
  end

  doc_for :close do
    api :PUT, '/work_orders/:id/close', 'Close work order'
    error 401, 'Unauthorized'
    error 500, "Server Error"
    error 404, "Not Found"

    description <<-EOS
      If successful, it returns a json containing <tt>work_order object</tt>

      WorkOrder object contains:
        id: id of work_order
        property_id: property_id of this work_order
        description: content/description
        priority: priority
        status: status
        due_to_date: due date
        assigned_to_id: user_id of this work_order is assigned to
        maintainable_type: maintainable_type
        other_maintainable_location: other maintainable location
        maintainable_id: maintainable_id
        opened_by_user_id: user_id who opened this work_order
        created_at: created_at
        updated_at: updated_at
        closed_by_user_id: user who closed this work order
        first_img_url: first img url
        second_img_url: second img url
        work_order_url: url to work order
        closed_at: datetime when closed
        closed: true if status is closed
        opened_at: datetime when this work order was opened
    EOS
  end

  doc_for :update do
    api :PUT, '/work_orders/:id', 'Update work order'
    error 401, 'Unauthorized'
    error 500, "Server Error"
    error 404, "Not Found"

    description <<-EOS
      If successful, it returns a json containing <tt>work_order object</tt>

      WorkOrder object contains:
        id: id of work_order
        property_id: property_id of this work_order
        description: content/description
        priority: priority
        status: status
        due_to_date: due date
        assigned_to_id: user_id of this work_order is assigned to
        maintainable_type: maintainable_type
        maintainable_id: maintainable_id
        opened_by_user_id: user_id who opened this work_order
        created_at: created_at
        updated_at: updated_at
        closed_by_user_id: user who closed this work order
        first_img_url: first img url
        second_img_url: second img url
        work_order_url: url to work order
        closed_at: datetime when closed
        closed: true if status is closed
        opened_at: datetime when this work order was opened
    EOS
  end

  doc_for :assignable_users do
    api :GET, '/work_orders/assignable_users'
    error 401, 'Unauthorized'
    error 500, "Server Error"
    error 404, "Not Found"

    description <<-EOS
      If successful, it returns a json containing <tt>a list of assignable users</tt> to work order.

      User object contains:
        id: id of user
        name_titleized: titleized name of user
    EOS
  end
end
