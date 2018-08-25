module Api::RoomsDoc
  extend BaseDoc

  namespace 'api'
  resource :rooms

  doc_for :checklist_items do
    api :GET, '/rooms/checklist_items', 'Get checklist items for rooms'
    error 401, 'Unauthorized'
    error 500, "Server Error"
    description <<-EOS
      If successful, it returns a list of json object containing info about room areas and <tt>checklist_item object list</tt>
      [
        {
          id: id of room area
          name: name of public area
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
        "id": 3699,
        "name": "Entrance Door",
        "checklist_items": [
            {
                "id": 3701,
                "name": "Door Lock"
            },
            {
                "id": 3700,
                "name": "Signage"
            },
            {
                "id": 3703,
                "name": "Threshold"
            },
            {
                "id": 3704,
                "name": "Door/Frame"
            },
            {
                "id": 3705,
                "name": "Weather Striping"
            },
            {
                "id": 3706,
                "name": "Door Closure"
            },
            {
                "id": 3707,
                "name": "Hinges"
            },
            {
                "id": 3708,
                "name": "Safety Latch"
            },
            {
                "id": 3709,
                "name": "Peephole"
            },
            {
                "id": 3710,
                "name": "Evacuation Plans"
            },
            {
                "id": 3702,
                "name": "Deadbolt"
            }
        ]
    },
    {
        "id": 3711,
        "name": "Vanity",
        "checklist_items": [
            {
                "id": 3713,
                "name": "Vinyl"
            },
            {
                "id": 3712,
                "name": "Closet"
            },
            {
                "id": 3715,
                "name": "Sink Drain"
            },
            {
                "id": 3716,
                "name": "Pipe Flanges"
            },
            {
                "id": 3717,
                "name": "Aerator"
            },
            {
                "id": 3718,
                "name": "Tissue Dispenser"
            },
            {
                "id": 3719,
                "name": "Towel Rack"
            },
            {
                "id": 3720,
                "name": "Mirror"
            },
            {
                "id": 3721,
                "name": "Light Fixture"
            },
            {
                "id": 3722,
                "name": "Carpet"
            },
            {
                "id": 3723,
                "name": "GFCI"
            },
            {
                "id": 3724,
                "name": "Hairdryer"
            },
            {
                "id": 3714,
                "name": "Vanity Top"
            }
        ]
    }
]
    EOS


  end



end
