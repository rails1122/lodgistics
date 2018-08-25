checklistDetailPage = ->
  return unless $('body').hasClass('task-list-detail-page')

  containerId = "#task-items-content"
  commentModalId = "#task-item-comment-modal"
  recordId = $(containerId).data("id")
  reviewTemplate = $("#task-item-review-template").html()
  taskItemsTemplate = $('#task-items-template').html()
  taskCategoryTemplate = $('#task-category-template').html()
  taskCategoryStatusTemplate = $('#task-category-status-template').html()
  taskItemTemplate = $('#task-item-template').html()
  taskListNameTemplate = $('#task-list-name-template').html()
  taskListRecord = {}
  currentItem = null
  currentStatus = null

  $container = $(containerId)
  $commentModal = $(commentModalId)

  findFirstCategory = ->
    for category in taskListRecord.categories
      return category unless category.allCompleted

  findCategoryElement = (category) ->
    $container.find(".task-category[data-id='#{category.id}']")

  findItemElement = (item) ->
    $container.find(".task-item[data-id='#{item.id}']")

  findItemWithElement = ($element) ->
    itemId = $element.parents("tr").data("id")
    categoryId = $element.parents(".task-category").data("id")
    category = taskListRecord.categories.find (elem) ->
      elem.id == categoryId
    item = category.item_records.find (elem) ->
      elem.id == itemId

  findCategoryWithItem = (item) ->
    for category in taskListRecord.categories
      for ir in category.item_records
        return category if item.id == ir.id

  collapseCategory = (category, option = "show") ->
    findCategoryElement(category).find(".collapse").collapse(option)

  expandFirstCategory = ->
    firstCategory = findFirstCategory()
    collapseCategory(firstCategory)

  initPlugins = ->
    $container.find('[data-toggle="tooltip"]').tooltip()

  renderTaskList = () ->
    updateRecordStatus()
    html = Mustache.render(taskItemsTemplate, taskListRecord,
      category: taskCategoryTemplate
      category_status: taskCategoryStatusTemplate
      task_item: taskItemTemplate
      review: reviewTemplate
      name: taskListNameTemplate
    )
    $container.html(html)
    initPlugins()
    $container.find(".collapse").collapse().collapse("hide")
    setTimeout(() ->
      expandFirstCategory()
    , 500)

  renderStatus = (item) ->
    category = findCategoryWithItem(item)
    $category = findCategoryElement(category)
    $header = $category.find(".category-status")
    html = Mustache.render(taskCategoryStatusTemplate, category)
    $header.replaceWith(html)
    for c in taskListRecord.categories
      $ce = findCategoryElement(c)
      if c.allCompleted
        $ce.find(".category-header").addClass("text-success")
      else
        $ce.find(".category-header").removeClass("text-success")

  renderItem = (item) ->
    updateRecordStatus()
    category = findCategoryWithItem(item)
    if category.allCompleted
      collapseCategory(category, "hide")
    $item = findItemElement(item)
    html = Mustache.render(taskItemTemplate, item)
    $item.replaceWith(html)
    initPlugins()
    renderStatus(item)
    expandFirstCategory()

  resetItemStatus = (item) ->
    $.ajax(
      url: Routes.reset_api_task_item_record_path(item.id)
      type: "POST"
      dataType: "json"
    ).done (response) ->
      Object.assign(item, response)
      renderItem(item)

  updateRecordStatus = () ->
    if taskListRecord.finished_at
      if taskListRecord.permission_to == 'review'
        taskListRecord.review = true
      else
        taskListRecord.view = true
    else
      taskListRecord.started = true
    for category in taskListRecord.categories
      category.total = category.item_records.length
      category.completed = category.item_records.filter((item) ->
        !!item.completed_at
      ).length
      category.allCompleted = category.total == category.completed
      category.started = taskListRecord.started
      for item in category.item_records
        item.started = taskListRecord.started

  updateItemStatus = (item, comment, status) ->
    $.ajax(
      url: Routes.complete_api_task_item_record_path(item.id)
      type: "POST"
      dataType: "json"
      data:
        task_item_record:
          comment: comment
          status: status
    ).done (response) ->
      Object.assign(item, response)
      $commentModal.modal("hide")
      renderItem(item)

  renderReviewInfo = (record) ->
    html = Mustache.render(reviewTemplate, record)
    $("#{containerId} .review-info").replaceWith(html)

  updateReviewStatus = (comment, status) ->
    $.ajax(
      url: Routes.review_api_task_list_record_path(taskListRecord.id)
      type: "POST"
      dataType: "json"
      data:
        notes: comment
        status: status
    ).done (response) ->
      Object.assign(taskListRecord, response)
      renderReviewInfo(taskListRecord)
      $commentModal.modal("hide")

  finishTaskList = (comment) ->
    $.ajax(
      url: Routes.finish_api_task_list_record_path(taskListRecord.id)
      type: "POST"
      dataType: "json"
      data:
        notes: comment
    ).done (response) ->
      window.location.href = Routes.task_lists_path()

  showReviewCommentModal = () ->
    if currentStatus == "review-comment"
      $commentModal.find(".btn-submit").text("Add Comment")
    else
      $commentModal.find(".btn-submit").text("Review")
    $commentModal.modal()

  loadTaskRecord = ->
    $.ajax(
      url: Routes.api_task_list_record_path(recordId)
      type: "GET"
      dataType: "json"
    ).done (response) ->
      taskListRecord = response
      renderTaskList()

  $(document).on "click", "#{containerId} .task-item-action", (e) ->
    e.preventDefault()
    return unless taskListRecord.started
    $this = $(@)
    currentItem = findItemWithElement($this)

    $commentModal.find(".comment-field").val(currentItem.comment)
    if !$this.hasClass("comment-item") && $this.hasClass("finished")
      showConfirmationDialog("Reset the status of '#{currentItem.title}'?", $this)
    else
      if $this.hasClass("finish-item")
        currentStatus = "completed"
        updateItemStatus(currentItem, '', currentStatus)
      else if $this.hasClass("comment-item")
        currentStatus = "comment"
        $commentModal.find(".comment-field").val("")
        $commentModal.find(".btn-submit").text("Comment")
        $commentModal.modal()

  $("#task-item-comment-modal").unbind("submit").submit (e) ->
    e.preventDefault()
    if (currentStatus == "comment" || currentStatus == "completed") && !currentItem
      return false
    comment = $commentModal.find(".comment-field").val()
    if currentStatus == "finish"
      finishTaskList(comment)
    else if currentStatus == "reviewed"
      updateReviewStatus(comment, currentStatus)
    else if currentStatus == "review-comment"
      updateReviewStatus(comment, currentStatus)
    else
      updateItemStatus(currentItem, comment, currentStatus)

  $(document).on "shown.bs.modal", commentModalId, (e) ->
    $(@).find(".comment-field").focus()

  $(document).on "hidden.bs.modal", commentModalId, (e) ->
    currentStatus = null
    currentItem = null

  $(document).on "dialog:confirmed", "#{containerId} .task-item-action", (e) ->
    e.preventDefault()
    item = findItemWithElement($(@))
    resetItemStatus(item)

  $(document).on "click", ".task-list-finish", (e) ->
    e.preventDefault()
    $this = $(@)
    showConfirmationDialog($this.data("message"), $this)

  $(document).on "click", ".task-list-review", (e) ->
    e.preventDefault()
    $this = $(@)
    showConfirmationDialog($this.data("message"), $this)

  $(document).on "dialog:confirmed", ".task-list-finish", (e) ->
    currentStatus = "finish"
    $commentModal.find(".btn-submit").text("Finish")
    $commentModal.modal()

  $(document).on "click", ".task-list-review-comment", (e) ->
    e.preventDefault()
    currentStatus = "review-comment"
    showReviewCommentModal()

  $(document).on "dialog:confirmed", ".task-list-review", (e) ->
    e.preventDefault()
    currentStatus = "reviewed"
    showReviewCommentModal()

  loadTaskRecord()


$(document).ready(checklistDetailPage)
