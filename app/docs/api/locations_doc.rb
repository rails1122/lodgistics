module Api::LocationsDoc
  extend BaseDoc

  namespace 'api'
  resource :locations

  doc_for :index do
    api :GET, '/locations', 'Get work orders for current property'

    description <<-EOS
      If successful, it returns a json containing <tt>a hash</tt> containing location information for current property.
        {
          'location_types' => [ 'Room', 'PublicArea', 'Equipment' ],
          'Room' => [ room_obj, ...],
          'PublicArea' => [ public_area_obj, ...],
          'Equipment' => [ equipment_obj, ...],
        }

      room_obj contains:
        id: id
        property_id: property id
        floor: floor
        room_number: room number

      public_area_obj contains:
        id: id
        property_id: property id
        name: name 
        row_order: row order

      equipment_obj contains:
        id: id
        property_id: property id
        make: make
        name: name
        location: location
        buy_date: buy date
        replacement_date: replacement date
        equipment_type_id: equipment type
        instruction: instruction
        liefspan: lifespan
        row_order: row order
    EOS
  end

end
