module Api::ChecklistItemsDoc
  extend BaseDoc

  namespace 'api'
  resource :checklist_items

  doc_for :index do
    api :GET, '/checklist_items', 'Get checklist items'
    error 401, 'Unauthorized'
    error 500, "Server Error"

    description <<-EOS
      If successful, it returns a json containing <tt>a list of checklist_item object</tt>

      WorkOrder object contains:
        id: id
        property_id: property_id
        name: name
        area_id: area_id
        maintenance_type: maintenance type
        row_order: row order?
        public_area_id: public area id
    EOS
  end


end
