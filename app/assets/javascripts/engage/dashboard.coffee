$ ->
  return unless $('body').hasClass('engage-dashboard')

  $messageTemplate = $('.engage-message-template')
  $replyTemplate = $(".engage-message-reply-template")
  $alarmTemplate = $('.engage-alarm-template')
  $pickupTemplate = $('.engage-pickup-template')
  $lostFoundTemplate = $('.engage-lost-found-template')

  $messageForm = $('#form-message')
  $replyForm = $("#reply-form")
  $messageTitle = $("#message-title")
  $followUpButton = null

  engageTypes = ['Message', 'Alarm', 'Pickup', 'Lost', 'Found']
  typeStarts = [
    [],
    ['wake up', 'wake-up', 'wakeup'], # alarm start words
    ['pickup', 'pick-up', 'pick up', 'drop off', 'drop-off', 'dropoff'], # pick up start words
    ['lost'], # lost start words
    ['found']
  ]
  typeIcons = ['ico-checkmark', 'ico-alarm']
  typeTemplates = [$messageTemplate, $alarmTemplate, $pickupTemplate, $lostFoundTemplate, $lostFoundTemplate]

  mentionedUserIds = []
  mentionedUserIdsOnComment = []

  getMentionableUserNames = ->
    gon.users_in_property.filter((e) -> !mentionedUserIds.includes(e.id)).map((e) -> e.name)
    #gon.users_in_property.map((e) -> e.name)

  getMentionableUserNamesOnComment = ->
    gon.users_in_property.filter((e) -> !mentionedUserIdsOnComment.includes(e.id)).map((e) -> e.name)

  setupAtWho = ->
    mentionable_user_names = getMentionableUserNames()
    $(".note-editable").atwho({
      at:"@",
      'data': mentionable_user_names,
      limit: mentionable_user_names.length,
      searchKey: 'name',
      callbacks: {
        beforeInsert: (value, $li) ->
          name = value.substring(1)
          mentioned_user_id = gon.users_in_property.find((e) -> e.name == name).id
          unless mentionedUserIds.includes(mentioned_user_id)
            mentionedUserIds.push(mentioned_user_id)
            setupAtWho()
            return value
      }
    })

  parseMessageType = (message) ->
    msg = message.toLowerCase()
    for types, typeIndex in typeStarts
      for startWord in types
        if msg.indexOf(startWord) == 0
          return typeIndex
    0

  parseEngageType = (engageType) ->
    type = engageType.toLowerCase()
    for eType, eIndex in engageTypes
      if type == eType.toLowerCase()
        return eIndex
    0

  $messageTitle.on 'input', (e) ->
    $(this).val $(this).val().toUpperCase()

  showMessageForm = ->
    $messageTitle
      .show()
      .val('')
    $('#btn-new-message')
      .html("<i class='ico-checkmark'/> <span class='hidden-xs'>Share</span>")
      .removeClass('btn-primary')
      .addClass('btn-success')
      .data("message-type", -1)
    $('#btn-cancel').show()
    $('#btn-print').hide()
    $('.note-editable').trigger('focus')
    $('.summernote').code('')
    clearImageUploadButton()
    clearFollowUpBroadcastButtons()

  hideMessageForm = ->
    $('#btn-new-message')
      .html("<i class='ico-plus-circle2'/> <span class='hidden-xs'>New Post</span>")
      .removeClass('btn-success')
      .addClass('btn-primary')
    $('#btn-cancel').hide()
    $('#btn-print').show()
    history.pushState("", document.title, window.location.pathname + window.location.search);


  parseMessageData = (message, messageType) ->
    searchMsg = message.toLowerCase()
    content = message
    # remove message type string
    if messageType > 0
      for startWord in typeStarts[messageType]
        if searchMsg.indexOf(startWord) == 0
          content = message.substring(startWord.length + 1)
          break
    searchMsg = content.toLowerCase()

    data =
      body: message

    # parse room number
    roomPart = searchMsg.match(/(?:^|\s+)room\s*(?:#|\d)\S*/)
    if roomPart
      roomNumber = roomPart[0].split(/[\s<.,]+/).splice(-1)[0]
      if !!roomNumber && roomNumber[0] == '#'
        roomNumber = roomNumber.substring(1)
      data.room_number = roomNumber if roomNumber
    # parse alaram time
    if messageType == 1
      results = chrono.parse(content)
      if results.length > 0
        data.due_date = results[0].start.date()
        data.body = content.substr(0, results[0].index - 1)
    if messageType == 0
      data.follow_up_start = $('#follow_up_start').val()
      data.follow_up_end = $('#follow_up_end').val()
      data.broadcast_start = $('#broadcast_start').val()
      data.broadcast_end = $('#broadcast_end').val()
    data

  filterMessages = (searchStr) ->
    groups = $(".message-panel")
    for group in groups
      $group = $(group)
      if $group.find(".message-detail").html().toLowerCase().indexOf(searchStr.toLowerCase()) >= 0
        $group.show()
      else
        $group.hide()
    $("#follow-up-count").text($(".follw-up-list .message-panel").filter(-> $(@).css("display") != "none").length)
    $("#message-count").text($(".message-list .message-panel").filter(-> $(@).css("display") != "none").length)

  updateRepliesStatus = (messageHtml, messageType) ->
    if messageType == 0
      repliesCount = messageHtml.find(".replies").find(".replied-messages").length
      messageHtml.find(".toggle-replies .count").text(repliesCount.toString())
      if repliesCount > 0
        messageHtml.find(".toggle-replies").css("display", "block")
      else
        messageHtml.find(".toggle-replies").css("display", "none")

  appendMessage = (message, messageType = 0) ->
    $parent = null
    engageType = engageTypes[messageType].toLowerCase()
    if message.follow_up_show
      $parent = $(".follow-up-list .panel-body")
    else
      $parent = $(".#{engageType}-list")
    messageHtml = $(Mustache.render(typeTemplates[messageType].html(), message, {reply: $replyTemplate.html()}))
    messageHtml.find('[data-toggle="tooltip"], .engage-tooltip').tooltip() unless window.isTouchDevice()
    updateRepliesStatus(messageHtml, messageType)
    if messageType != 0 || message.follow_up_show || message.show_up
      if messageType == 0
        $parent.prepend(messageHtml)
      else
        $parent.append(messageHtml)
      if messageType == 0
        itemClass = ".message-panel"
      else
        itemClass = ".#{engageType}"
      if message.follow_up_show
        $("#follow-up-count").text($("#follow-up-count").parents(".panel").find(itemClass).length)
      else
        $("##{engageType}-count").text($("##{engageType}-count").parents(".panel").find(itemClass).length)
      reloadLightbox()

  appendReply = (reply) ->
    replyHtml = Mustache.render($replyTemplate.html(), reply)
    $parent = $(".message-panel[data-id='#{reply.parent_id}']")
    $parent.find(".replies").prepend(replyHtml)
    updateRepliesStatus($parent, 0)

  ajaxSaveMessage = (data, url, messageType) ->
    console.log(url)
    console.log(data)
    if messageType != 0 && !!data.entity.due_date
      data.entity.due_date = moment(data.entity.due_date).format("YYYY-MM-DD HH:mm::ss")

    # Convert generic +data+ Hash into +FormData+
    fd = new FormData()
    if data.file
      file = data.file
      delete data.file
    jQuery.param(data).split('&').forEach (e) ->
      [k,v] = e.split('=')
      fd.append decodeURIComponent(k), decodeURIComponent(v.replace(/\+/g,'%20'))
      return
    if file
      fd.append 'message[image]', file

    $.ajax(url,
      dataType: "json"
      type: "POST"
      data: fd
      cache: false
      contentType: false
      processData: false
    ).done (data)->
      if messageType == 1
        engageType = engageTypes[messageType].toLowerCase()
        loadMessages(engageType, selectedDate(engageType))
      else
        appendMessage(data, messageType)
        mentionedUserIds = []
    .error (xhr, ajaxOptions, thrownError) ->
      $.gritter.add(text: xhr.responseText, class_name: "alert alert-danger")

  saveMessage = (message, messageType) ->
    engageType = engageTypes[messageType].toLowerCase()
    messageData =
      date: selectedDate(engageTypes[messageType].toLowerCase()).format()
    if messageType == 0
      messageData[engageType] = parseMessageData(message, messageType)
      messageData[engageType].title = $messageTitle.val().toUpperCase()
      messageData[engageType].mentioned_user_ids = mentionedUserIds
    else
      messageData.entity = parseMessageData(message, messageType)
      messageData.entity.entity_type = engageType
    url = if messageType == 0 then Routes.engage_messages_path() else Routes.engage_entities_path()
    if messageType == 0
      if $('.note-image-input').prop('files').length == 1
        messageData.file = $('.note-image-input').prop('files')[0]
      ajaxSaveMessage(messageData, url, messageType)
    else if messageType == 1
      $('#alarmConfirmationDialog').data('alarm', messageData)
      $('#alarmConfirmationDialog').data('url', url)
      $('#alarmConfirmationDialog #message').html(messageData.entity.body)
      $('#alarmConfirmationDialog #alarm_at').text(moment(messageData.entity.due_date).format('MMM DD, hh:mm A'))
      $('#alarmConfirmationDialog').modal()

  $('#alarmConfirmationDialog .confirm').on 'click', (e) ->
    ajaxSaveMessage($("#alarmConfirmationDialog").data('alarm'), $("#alarmConfirmationDialog").data("url"), 1)

  reloadLightbox = ->
    $('.image-link').magnificPopup({type: 'image'});
    return

  updateThreadAndFollowUp = ->
    for group in $(".message-group")
      $group = $(group)
      if $group.find(".message-panel").length == 0
        $group.remove()
    if $(".follow-up-list .message-panel").length == 0
      $(".follow-up-list").hide()
    else
      $(".follow-up-list").show()

  updateMessage = (message, messageType = 0) ->
    engageType = engageTypes[messageType].toLowerCase()
    messageHtml = $(Mustache.render(typeTemplates[messageType].html(), message))
    messageHtml.find('[data-toggle="tooltip"], .engage-tooltip').tooltip()  unless window.isTouchDevice()
    updateRepliesStatus(messageHtml, messageType)
    if messageType == 0
      $prev = $(".message-panel[data-id='#{message.id}']")
    else
      $prev = $(".#{engageType}[data-id='#{message.id}']")
    $prev.find('[data-toggle="tooltip"], .engage-tooltip').tooltip('destroy')  unless window.isTouchDevice()
    if messageType == 0
      if message.broadcast_show
        window.globalMessages.addMessage(message)
      else
        window.globalMessages.removeMessage(message.id)
    if $prev.data("follow-up") == message.follow_up_show
      $prev.replaceWith(messageHtml)
    else
      $prev.remove()
      appendMessage(message, messageType, false)
    updateThreadAndFollowUp()

  removeMessage = (messageId, messageType = 0) ->
    engageType = engageTypes[messageType].toLowerCase()
    $element =
      if messageType == 0
        $(".message-panel[data-id='#{messageId}']")
      else
        $(".#{engageType}[data-id='#{messageId}']")
    $element.remove()
    if messageType == 0
      itemClass = ".message-panel"
    else
      itemClass = ".#{engageType}"
    $("##{engageType}-count").text($("##{engageType}-count").parents(".panel").find(itemClass).length)

  ajaxUpdateMessage = (messageId, data, messageType = 0) ->
    data.date = selectedDate(engageTypes[messageType].toLowerCase()).format()
    $(".loading").show()
    url = if messageType == 0 then Routes.engage_message_path(messageId) else Routes.engage_entity_path(messageId)
    $.ajax(url,
      type: "PUT"
      data: data
    ).done (message) ->
      updateMessage(message, messageType)
    .error (xhr, ajaxOptions, thrownError) ->
      $.gritter.add(text: xhr.responseText, class_name: "alert alert-danger")
    .complete -> $(".loading").hide()

  ajaxRemoveMessage = (messageId, messageType = 0) ->
    url = if messageType == 0 then Routes.engage_message_path(messageId) else Routes.engage_entity_path(messageId)
    $(".loading").show()
    $.ajax(url,
      type: "DELETE"
    ).done () ->
      removeMessage(messageId, messageType)
    .error (xhr) ->
      $.gritter.add(text: xhr.responseText, class_name: "alert alert-danger")
    .complete -> $(".loading").hide()

  afterDateChange = (engageType, date, $selector) ->
    messageType = parseEngageType(engageType)
    console.log messageType
    if messageType == 1
      if isToday(date)
        $selector.find(".date-value").hide()
        $selector.find(".btn-next-day").hide()
      else
        $selector.find(".date-value").show()
        $selector.find(".btn-next-day").show()

  loadMessages = (engageType, date) ->
    messageType = parseEngageType(engageType)
    $("##{engageType}-count").text(0)
    if messageType == 0
      $messageList = $(".message-list")
      $(".loading").show()
      $.ajax(Routes.engage_messages_path(date: date.format()),
        type: "GET"
      ).done (messages) ->
        $messageList.html("")
        $(".follow-up-list .panel-body").html("")
        for msg in messages
          appendMessage(msg)
        updateThreadAndFollowUp()
      .complete -> $(".loading").hide()
    else
      $entityList = $(".#{engageType}-list")
      $entityList.parent().find(".loading").show()
      $.ajax(Routes.engage_entities_path(date: date.format(), type: engageType),
        type: "GET"
      ).done (entities) ->
        $entityList.html("")
        for msg in entities
          appendMessage(msg, messageType)
      .complete -> $entityList.parent().find(".loading").hide()

  updateMentionedUserIds = ->
    # if txt does not contain mentioned user name, remove that user from mentionedUserIds
    txt = $(".summernote").code()
    updated_user_ids =
      mentionedUserIds.filter((id) ->
        u = gon.users_in_property.find((u) -> u.id == id)
        at_name = "@#{u.name}"
        txt.includes(at_name)
      )
    if (updated_user_ids.length != mentionedUserIds.length)
      mentionedUserIds = updated_user_ids
      setupAtWho()

  addImageUploadButton = ->
    $('.note-insert .btn').attr('data-event': '').html('<i class="ico-attachment"></i>')
    $('.note-image-input').on 'change', ->
      if $(this).prop('files').length == 1
        filename = $(this).prop('files')[0].name
        $('.note-insert .filename').remove()
        $('.note-insert').append("<div class='filename'><span class='ico-close2 remove-image' /><span class='name'>#{filename}</span></div>")
        $('.note-insert .btn').addClass('selected')
        $('.note-insert .filename .remove-image').on 'click', ->
          clearImageUploadButton()
          false
        $('.note-insert .filename .name').on 'click', ->
          $('.note-image-input').click()
          false
      return
    $('.note-insert .btn').on 'click', ->
      $('.note-image-input').click()
      return false
    return

  hackSummernoteToolbar = ->
    $('.note-toolbar .note-insert')
      .addClass('keep')
      .after('<div class="btn-group calendar-btns keep"><button type="button" class="btn btn-default broadcast" data-toggle="tooltip" data-container="body" data-placement="bottom" title-cancel="Cancel Broadcast." title="Broadcast the message at the top of the Lodgistics app. Select a date or a range of dates."><i class="ico-bullhorn"></i></button></div>')
      .after('<div class="btn-group calendar-btns keep"><button type="button" class="btn btn-default follow-up" data-toggle="tooltip" data-container="body" data-placement="bottom" title-cancel="Cancel Follow up." title="Follow up on the message on a future date. Select a date or a range of dates."><i class="ico-calendar"></i></button></div>')
    $('.note-toolbar > :not(.keep)')
      .wrapAll('<div class="popover right in"><div class="popover-content" /><div class="arrow" /></div>')
    $('.note-toolbar .popover')
      .before('<button type="button" class="btn btn-default hack-toggle-format" data-toggle="tooltip" data-container="body" data-placement="bottom" title="Formatting options"><i class="ico-font"></i></button>')
    $('.note-toolbar > :not(.keep)')
      .wrapAll('<div class="btn-group keep">')
    $('.hack-toggle-format').on 'click', (e) ->
      $(this).tooltip('hide')
      $('.note-toolbar .popover').toggle()
      false
    $('.note-toolbar [data-toggle=tooltip]').tooltip('setContent')
    return

  clearImageUploadButton = ->
    $('.note-insert .filename').remove()
    $('.note-image-input').val('')
    $('.note-insert .btn').removeClass('selected')

  $.summernote.lang["en-US"].image.image = "Attach Image"
  $('.summernote').summernote({
    height: 150,
    focus: true,
    disableDragAndDrop: true,
    toolbar: [
      ['insert', ['picture']]
      ['style', ['style']]
      ['style', ['bold', 'italic', 'underline', 'clear']]
      ['fontsize', ['fontsize']]
      ['color', ['color']]
      ['para', ['ul', 'ol']]
    ],
    oninit: ->
      $(".note-editor").addClass("needsclick")
      $(".note-editable").addClass("needsclick")
      setupAtWho()
      addImageUploadButton()
      hackSummernoteToolbar()
    onpaste: (e) ->
      bufferText = ((e.originalEvent || e).clipboardData || window.clipboardData).getData('Text')
      e.preventDefault()
      document.execCommand('insertText', false, bufferText);
    onkeyup: (e) ->
      updateMentionedUserIds()
      message = $('.summernote').code()
      messageType = parseMessageType(message)
      typeString = engageTypes[messageType]
      typeString = "Wake Up Call" if messageType == 1
      typeIcon = typeIcons[messageType]
      if messageType > 0
        $messageTitle.hide()
      else
        $messageTitle.show()
      $('#btn-new-message')
        .html("<i class='#{typeIcon}'/> <span class='hidden-xs'>Save #{typeString}</span>")
        .data("message-type", messageType)
  })

  selectedDate = (engageType) ->
    moment($(".date-selector[data-type='#{engageType}']").find(".date-value").datepicker("getDate"))

  dateLabel = (date) ->
    if isToday(date)
      'Today'
#    else if isYesterday(date)
#      'Yesterday'
#    else if isTomorrow(date)
#      'Tomorrow'
    else
      date.format('MM/DD/YYYY')

  isToday = (date) ->
    date.format('MMDDYYYY') == moment().format('MMDDYYYY')
  isYesterday = (date) ->
    date.format('MMDDYYYY') == moment().add(-1, 'd').format('MMDDYYYY')
  isTomorrow = (date) ->
    date.format('MMDDYYYY') == moment().add(1, 'd').format('MMDDYYYY')

  $('.date-value').datepicker
    maxDate: '0'
    onSelect: (selectedDate) ->
      engageType = $(@).parents(".date-selector").data("type")
      date = moment(selectedDate)
      afterDateChange(engageType, date, $(@).parents(".date-selector"))
      loadMessages(engageType, date)
      $(@).val(dateLabel(date))

  $(".btn-prev-day").on "click", $.debounce(250, ->
    $selector = $(@).parents(".date-selector")
    engageType = $selector.data("type")
    date = selectedDate(engageType)
    date = date.add(-1, 'd')
    afterDateChange(engageType, date, $selector)
    loadMessages(engageType, date)
    $selector.find(".date-value").val(dateLabel(date))
  )

  $(document).on "click", ".mark-done", (e) ->
    e.preventDefault()
    alarmId = $(@).parents(".alarm").data("id")
    ajaxUpdateMessage(alarmId,
      entity:
        complete: true
      , 1
    )

  $(document).on "click", ".uncomplete-alarm", (e) ->
    e.preventDefault()
    showConfirmationDialog("Revert alarm?", $(@))

  $(document).on "dialog:confirmed", ".uncomplete-alarm", (e) ->
    alarmId = $(@).parents(".alarm").data("id")
    ajaxUpdateMessage(alarmId,
      entity:
        complete: false
      , 1
    )

  $(document).on "click", ".alarm .delete", (e) ->
    e.preventDefault()
    showConfirmationDialog("Remove Alarm?", $(@))

  $(document).on "dialog:confirmed", ".delete", (e) ->
    alarmId = $(@).parents(".alarm").data("id")
    ajaxRemoveMessage(alarmId, 1)

  $(document).on "click", ".message-panel .add-work-order", ->
    window.workOrderSource = $(@)

  $(document).on "work_order_created", ".add-work-order", (event, workOrderId) ->
    messageId = $(@).parents(".message-panel").data("id")
    ajaxUpdateMessage(messageId,
      message:
        work_order_id: workOrderId
    ) if messageId

  $(".btn-next-day").on "click", $.debounce(250, ->
    $selector = $(@).parents(".date-selector")
    engageType = $selector.data("type")
    date = selectedDate(engageType)
    date = date.add(1, 'd')
    afterDateChange(engageType, date, $selector)
    loadMessages(engageType, date)
    $selector.find(".date-value").val(dateLabel(date))
  )

  for engageType in engageTypes
    loadMessages(engageType.toLowerCase(), moment())

  expandForm = () ->
    if window.location.hash.substr(1) == 'expanded'
      $('#form-message').collapse('show')
      showMessageForm()

  $(window).on "hashchange", () -> 
    expandForm()

  expandForm()

  $('#search-query').on 'input', $.debounce(250, ->
    searchString = $('#search-query').val()
    filterMessages(searchString)
  )

  $(document).on "click", ".complete-task", (e) ->
    e.preventDefault()
    messageId = $(@).parents(".message-panel").data("id")
    ajaxUpdateMessage(messageId,
      message:
        complete: true
    )

  $(document).on "dialog:confirmed", ".uncomplete-task", (e) ->
    messageId = $(@).parents(".message-panel").data("id")
    ajaxUpdateMessage(messageId,
      message:
        complete: false
    )

  $(document).on "click", ".uncomplete-task", (e) ->
    e.preventDefault()
    showConfirmationDialog("Revert task?", $(@))

  $(document).on 'click', '.panel-ribbon:not(.liked)', (e) ->
    e.preventDefault()
    messageId = $(@).parents('.message-panel').data('id')
    ajaxUpdateMessage(messageId,
      message:
        like: true
    )

  $(document).on "submit", ".reply-form", (e) ->
    e.preventDefault()
    $this = $(@)
    replyMsg = $this.find("textarea").val()
    parentId = $this.parents(".message-panel").data("id")
    $(".loading").show()
    $.ajax(Routes.engage_messages_path(),
      dataType: "json"
      type: "POST"
      data:
        date: selectedDate('message').format()
        message:
          parent_id: parentId
          body: replyMsg
          mentioned_user_ids: mentionedUserIdsOnComment
    ).done (data)->
      appendReply(data)
      $this.collapse('hide')
      mentionedUserIdsOnComment = []
    .error (xhr, ajaxOptions, thrownError) ->
      $.gritter.add(text: xhr.responseText, class_name: "alert alert-danger")
    .complete -> $(".loading").hide()
    false

  setupAtWhoOnComments = (textarea) ->
    mentionable_user_names = getMentionableUserNamesOnComment()
    textarea.atwho({
      at:"@",
      'data': mentionable_user_names,
      limit: mentionable_user_names.length,
      searchKey: 'name',
      callbacks: {
        beforeInsert: (value, $li) ->
          name = value.substring(1)
          mentioned_user_id = gon.users_in_property.find((e) -> e.name == name).id
          unless mentionedUserIdsOnComment.includes(mentioned_user_id)
            mentionedUserIdsOnComment.push(mentioned_user_id)
            setupAtWhoOnComments(textarea)
            return value
      }
    })

  $(document).on "show.bs.collapse", ".reply-form", (e) ->
    $(@).parents(".message-panel").find(".replies.collapse").collapse("show")
    mentionedUserIdsOnComment = []
    textarea = $(@).find("textarea")
    textarea.val("")
      .trigger("focus")
      .on 'keyup', (e) ->
        # if txt does not contain mentioned user name, remove that user from mentionedUserIdsOnComment
        txt = $(this).val()
        updated_user_ids =
          mentionedUserIdsOnComment.filter((id) ->
            u = gon.users_in_property.find((u) -> u.id == id)
            at_name = "@#{u.name}"
            txt.includes(at_name)
          )
        if (updated_user_ids.length != mentionedUserIdsOnComment.length)
          mentionedUserIdsOnComment = updated_user_ids
          setupAtWhoOnComments(textarea)
    setupAtWhoOnComments(textarea)

  $(document).on "show.bs.collapse", ".replies", (e) ->
    $(@).parents(".message-panel").find(".toggle-replies .toggle-message").text("Hide Comments")

  $(document).on "hide.bs.collapse", ".replies", (e) ->
    $(@).parents(".message-panel").find(".toggle-replies .toggle-message").text("Show Comments")


  updateFollowUp = (start, end) ->
    $panel = $followUpButton.parents(".message-panel")
    messageId = $panel.data("id")
    if typeof messageId is 'undefined'
      range = " (#{start.format('MMM D')} - #{end.format('MMM D')})"
      $followUpButton.children('i').first().after("<span>#{range}</span>")
      $followUpButton \
        .attr('title-normal', $followUpButton.attr('data-original-title')) \
        .attr('data-original-title', $followUpButton.attr('title-cancel')) \
        .tooltip('setContent')
      if $followUpButton.hasClass("broadcast") || $followUpButton.hasClass("cancel-broadcast")
        $('#broadcast_start').val start.format()
        $('#broadcast_end').val end.format()
        $followUpButton.removeClass('broadcast').addClass('cancel-broadcast')
      else
        $('#follow_up_start').val start.format()
        $('#follow_up_end').val end.format()
        $followUpButton.removeClass('follow-up').addClass('cancel-follow-up')
      return
    if $followUpButton.hasClass("broadcast") || $followUpButton.hasClass("cancel-broadcast")
      ajaxUpdateMessage(messageId,
        message:
          broadcast_start: start.format()
          broadcast_end: end.format()
      )
    else
      ajaxUpdateMessage(messageId,
        message:
          follow_up_start: start.format()
          follow_up_end: end.format()
      )

  clearFollowUpBroadcastButtons = ->
    $('#form-message input[type=hidden]').val('')
    $('#form-message .calendar-btns span').remove()
    $('#form-message .calendar-btns button').each (i) ->
      $(this).removeClass('cancel-follow-up cancel-broadcast') \
        .attr('data-original-title', $(this).attr('title-normal')) \
        .tooltip('setContent')
      if $(this).has('.ico-calendar').length == 1
        $(this).addClass('follow-up')
      else
        $(this).addClass('broadcast')
      return
    return

  $("#follow-up-picker").on "apply.daterangepicker", (ev, picker) ->
    updateFollowUp(picker.startDate, picker.endDate)

  $('#follow-up-picker')
    .daterangepicker(
      alwaysShowCalendars: true
      linkedCalendars: false
      opens: 'right'
    )
    .on("show.daterangepicker", (e, picker) ->
      offset = $followUpButton.offset()
      $(".daterangepicker")
        .css("top", "#{offset.top + 21}px")
        .css("left", "#{offset.left - 12}px")
    )
    .on("showCalendar.daterangepicker", (e, picker) ->
      offset = $followUpButton.offset()
      $(".daterangepicker")
      .css("top", "#{offset.top + 21}px")
      .css("left", "#{offset.left - 12}px")
    )

  $(document).on "click", ".follow-up, .broadcast", (e) ->
    $followUpButton = $(@)
    $('#follow-up-picker').data("daterangepicker").setStartDate(moment())
    $('#follow-up-picker').data("daterangepicker").setEndDate(moment())
    setTimeout(->
      $('#follow-up-picker').trigger("click")
    , 50)

  $(document).on "dialog:cancelled", ".cancel-follow-up, .cancel-broadcast", (e) ->
    $followUpButton = $(@)
    $('#follow-up-picker').data("daterangepicker").setStartDate(moment($followUpButton.data("start")))
    $('#follow-up-picker').data("daterangepicker").setEndDate(moment($followUpButton.data("end")))
    setTimeout(->
      $('#follow-up-picker').trigger("click")
    , 50)

  $(document).on "dialog:confirmed", ".cancel-follow-up, .cancel-broadcast", (e) ->
    $panel = $followUpButton.parents(".message-panel")
    messageId = $panel.data("id")
    if typeof messageId is 'undefined'
      $followUpButton.find('span').remove()
      $followUpButton \
        .attr('data-original-title', $followUpButton.attr('title-normal')) \
        .tooltip('setContent')
      if $followUpButton.hasClass("cancel-broadcast")
        $('#broadcast_start').val null
        $('#broadcast_end').val null
        $followUpButton.addClass('broadcast').removeClass('cancel-broadcast')
      else
        $('#follow_up_start').val null
        $('#follow_up_end').val null
        $followUpButton.addClass('follow-up').removeClass('cancel-follow-up')
      return
    if $followUpButton.hasClass("cancel-broadcast")
      ajaxUpdateMessage(messageId,
        message:
          broadcast_start: null
          broadcast_end: null
      )
    else
      ajaxUpdateMessage(messageId,
        message:
          follow_up_start: null
          follow_up_end: null
      )

  $(document).on "click", ".cancel-follow-up, .cancel-broadcast", (e) ->
    e.preventDefault()
    $followUpButton = $(@)
    if $followUpButton.hasClass("cancel-broadcast")
      showConfirmationDialog("Cancel broadcast?", $(@))
    else
      showConfirmationDialog("Cancel follow up?", $(@))

  $(document).on "click", "#btn-new-message", (e) ->
    messageType = $(@).data("message-type")
    if messageType >= 0
      saveMessage($(".summernote").code(), messageType)

  $("#btn-print").on 'click', (e) ->
    url = "/engage/dashboard.pdf?date=#{selectedDate('message').format('DD/MM/YYYY')}"
    window.open(url, '_blank')

  $messageForm.on "show.bs.collapse", ->
    showMessageForm()

  $messageForm.on "hide.bs.collapse", (e) ->
    hideMessageForm()

  $('#btn-cancel').on 'click', (e) ->
    $messageForm.collapse('hide')

  return
