module Api::PublicAreasDoc
  extend BaseDoc

  namespace 'api'
  resource :public_areas

  doc_for :all_checklist_items do
    api :GET, '/public_areas/checklist_items', 'Get checklist items for all public areas'
    error 401, 'Unauthorized'
    error 500, "Server Error"

    description <<-EOS
      If successful, it returns a json hash containing info about public areas and <tt>checklist_item object list</tt>
      [
        {
          id: id of public area
          name: name of public area
          property_id: property id
          checklist_items => [ { id: checklist_item id, name: checklist_item name }, ... ],
        },
        ...
      ]


      checklist_item object contains:
        id: id
        name: name
    EOS
    example <<-EOS
GET /api/public_areas/checklist_items
[
    {
        "id": 238,
        "name": "Entrance Doors",
        "property_id": 33,
        "checklist_items": [
            {
                "id": 3792,
                "name": "Door closure"
            },
            {
                "id": 3791,
                "name": "Doors/frames"
            },
            {
                "id": 3790,
                "name": "Thresholds"
            },
            {
                "id": 3789,
                "name": "Locks"
            }
        ]
    },
    {
        "id": 239,
        "name": "Meeting Room",
        "property_id": 33,
        "checklist_items": [
            {
                "id": 3803,
                "name": "Vents"
            },
            {
                "id": 3802,
                "name": "Pictures"
            },
            {
                "id": 3801,
                "name": "Electrical Plates"
            },
            {
                "id": 3800,
                "name": "Light Fixtures"
            },
            {
                "id": 3799,
                "name": "Vinyl"
            },
            {
                "id": 3798,
                "name": "Audio Visual Board"
            },
            {
                "id": 3797,
                "name": "Furniture"
            },
            {
                "id": 3796,
                "name": "Ceiling"
            },
            {
                "id": 3795,
                "name": "Carpet"
            },
            {
                "id": 3794,
                "name": "Drapery"
            },
            {
                "id": 3793,
                "name": "Windows"
            }
        ]
    }
]
    EOS

  end

  doc_for :checklist_items do
    api :GET, '/public_areas/:public_area_id/checklist_items', 'Get list of checklist_item for given public_area'
    param :public_area_id, Integer, desc: 'public_area id', required: true
    error 401, 'Unauthorized'
    error 500, "Server Error"
    description <<-EOS
      If successful, it returns a json list containing <tt>checklist_item object</tt> for given public_area
      checklist_item object contains:
        id: id
        property_id: property_id
        name: name
        area_id: area id
        maintenance_type: type (e.g. rooms, public areas)
        public_area_id: public_area_id
    EOS

  end



end
