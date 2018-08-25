roomSelectionPage = ->
  return unless $('body').hasClass('room-selection-page')

  rooms = []
  rooms_floor_template = $('#rooms-floor-template').html()
  lastPMDetailTemplate = $("#room-last-pm-detail").html()
  PRIORITIES = {
    "l": "Low",
    "m": "Medium",
    "h": "High"
  }

  prepareLastPMMessage = () ->
    for floor in rooms
      for room in floor.rooms
        if room.last_pm_record
          issues = []
          if room.last_pm_record.fixed > 0
            if room.last_pm_record.fixed == 1
              issues.push("1 issue fixed")
            else
              issues.push("#{room.last_pm_record.fixed} issues fixed")
          if room.last_pm_record.work_orders > 0
            if room.last_pm_record.work_orders == 1
              issues.push("1 WO created")
            else
              issues.push("#{room.last_pm_record.work_orders} WOs created")
          if room.last_pm_record.work_orders == 0 && room.last_pm_record.fixed == 0
            room.last_pm_record.has_issues = false
            issues.push "No Issues"
          else
            room.last_pm_record.has_issues = true
          room.last_pm_details = issues.join(" and ")
  
  findRoom = (roomId) ->
    for floor in rooms
      for room in floor.rooms
        return room if room.id == roomId

  floorDetails = (oTable, nTr) ->
    floor_index = $(nTr).attr('data-floor-index')
    $html = $(Mustache.render(rooms_floor_template, rooms[floor_index]))
    $html

  $("#room-selection-table thead tr").each ->
    this.insertBefore(document.createElement("th"), this.childNodes[0])

  roomsTable = $("#room-selection-table").dataTable(
    aoColumnDefs: [
      bSortable: false
      aTargets: [0]
    ]
    bPaginate: false
    bInfo: false
    bSort: false
  )

  load_and_build_rooms_table = (filter_type = 'remaining')->
    roomsTable.api().clear().draw()
    $('#main .indicator').removeClass('hide')
    $(".dataTables_empty").text("Fetching the rooms...")
    $.ajax(Routes.maintenance_rooms_path(filter_type: filter_type), {type: 'GET', dataType: 'json'})
    .done (rooms_by_floor)->
      roomsTable.api().clear().draw()
      rooms = rooms_by_floor
      prepareLastPMMessage()
      if rooms.length == 0
        $(".dataTables_empty").text("No rooms available.")
      $(rooms).each (index) ->
        roomsTable.api().row.add([
          '<a href="#" class="text-primary floor-toggler" style="text-decoration:none;font-size:14px;"><i class="ico-plus-circle"></i></a>'
          "Floor #{@.floor}"
          """<span class="label label-success">#{ @.rooms.length }</span>"""
        ]).draw().nodes().to$().addClass('floor-row').attr('data-floor-index', index).find('td:eq(2)').addClass('text-center')
    .complete (data) -> $('#main .indicator').addClass('hide')

  load_and_build_rooms_table()

  renderLastPMDetail = (room) ->
    details = room.last_pm_record.details
    details.opened = details.work_orders.filter((wo) ->
      wo.status == "open"
    ).length
    details.closed = details.work_orders.filter((wo) ->
      wo.status == "closed"
    ).length
    details.work_orders.sort((a, b) ->
      if a.status == "open"
        return -1
      else if a.status == "closed" && b.status == "open"
        return 1
      else if a.status == "working" && b.status != "working"
        return 1
      else
        return 0
    )
    for wo in details.work_orders
      wo.priority_detail = PRIORITIES[wo.priority]
      wo.status_detail = wo.status.charAt(0).toUpperCase() + wo.status.substr(1)
    $html = Mustache.render(lastPMDetailTemplate, details)
    $("tr[data-id='#{room.id}'] .last-pm-detail").html($html)

  toggleLastPMDetail = (room) ->
    $room = $("tr[data-id='#{room.id}']")
    $handle = $room.find(".arrow")
    $content = $room.find(".last-pm-detail")
    $content.slideToggle()
    $handle.toggleClass("expanded")

  $(document).on "click", ".last-pm-record .arrow", (e) ->
    roomId = $(@).parents("tr").data("id")
    room = findRoom(roomId)
    lastPMId = room.last_pm_record.id
    if room.last_pm_record.details
      toggleLastPMDetail(room)
    else
      $.ajax(Routes.maintenance_record_path(lastPMId), {type: 'GET', dataType: 'json'})
      .done (data) ->
        room.last_pm_record.details = data
        renderLastPMDetail(room)
        toggleLastPMDetail(room)

  $('a[data-filter-type]').on 'click', ->
    filterType = $(@).data('filter-type')
    load_and_build_rooms_table(filterType)
    if filterType == 'remaining'
      $(".fitler-title").text("Remaining")
    else if filterType == 'missed'
      $(".filter-title").text("Missed")
    else if filterType == 'in_progress'
      $(".filter-title").text("In Progress")
    $(@).siblings().removeClass('btn-primary').addClass('btn-default')
    $(@).addClass('btn-primary').removeClass('btn-default')

  $('body').on('click', '#room-selection-table tr.floor-row', (e) ->
    nTr = $(this)[0]
    $(nTr).toggleClass("open")
    if roomsTable.fnIsOpen(nTr)
      $(this).find('.floor-toggler').children().attr("class", "ico-plus-circle")
      roomsTable.fnClose(nTr)
    else
      $(this).find('.floor-toggler').children().attr("class", "ico-minus-circle")
      roomsTable.fnOpen(nTr, floorDetails(roomsTable, nTr), "details np")
      width = parseInt($('#room-selection-table thead th:first-child').css('width')) +
          parseInt($('#room-selection-table thead th:nth-child(2)').css('width')) -
          (parseInt($('#room-selection-table').css('border-width')) || 0)
      $(nTr).next().find('tr td:first-child').attr('width', width)
    e.preventDefault()
  )

$(document).ready(roomSelectionPage)
