checklistSetupPage = ->
  return unless $('body').hasClass('task-list-setup-page')

  taskLists = []
  $container = $(".task-lists")
  $taskListTemplate = $("#checklist-template").html()
  $categoryTemplate = $("#checklist-category-template").html()
  $categoryModal = $("#category-modal")
  $categoryFormTemplate = $("#category-form-template").html()
  $categoryItemTemplate = $("#category-item-template").html()

  currentTaskList = null

  xeditableOptions =
    params: (params)->
      {task_item: {title: params.value}}
    validate: (val)->
      return 'This field is required' if $.trim(val) is ''
    success: (response, newValue) ->
      id = currentTaskList.id
      categoryId = $(@).parents("form").data("id")
      itemId = $(@).parents(".checklist-item").data("id")
      category = currentTaskList.categories.find (c) ->
        c.id == categoryId
      item = category.items.find (i) ->
        i.id == itemId
      item.title = response.title
      null

  PANEL_CLASSES = ['panel-inverse', 'panel-success', 'panel-danger', 'panel-primary', 'panel-teal', 'panel-info']

  findTaskListElement = (id) ->
    $(".task-list[data-id='#{id}']")

  findCategoryElement = (id) ->
    $(".checklist-category[data-id='#{id}']")

  findTaskListId = (element) ->
    $(element).parents(".task-list").data("id")

  findCategoryId = (element) ->
    $(element).parents(".checklist-category").data("id")

  deleteTaskList = (id) ->
    $list = findTaskListElement(id)
    $.ajax(
      url: Routes.api_task_list_path(id)
      type: 'DELETE'
    ).done () ->
      $list.remove()
      taskLists = taskLists.filter (list) ->
        list.id != id
      updatePanelClasses()

  prepareItem = (item) ->
    item.update_url = Routes.api_task_item_path(item.id)

  showCategoryModal = (taskListId, categoryId) ->
    taskList = taskLists.find (list) ->
      list.id == taskListId
    currentTaskList = taskList
    category = {}
    if categoryId
      category = taskList.categories.find (category) ->
        category.id == categoryId
      for item in category.items
        prepareItem(item)
    $form = $(Mustache.render($categoryFormTemplate, category, {item: $categoryItemTemplate}))
    $form.find('.x-editable').editable(xeditableOptions)
    $categoryModal.find(".modal-dialog").html($form)
    $categoryModal.modal("show")

  renderCategory = (category, isNew) ->
    $taskList = findTaskListElement(currentTaskList.id)
    $html = Mustache.render($categoryTemplate, category)
    if isNew
      $taskList.find(".items-listing").append($html)
    else
      findCategoryElement(category.id).replaceWith($html)

  renderCategoryForm = (category) ->
    $html = Mustache.render($categoryFormTemplate, category)
    $categoryModal.find(".modal-dialog").html($html)

  saveCategory = (categoryId) ->
    category = null
    url = null
    title = $("#category-title").val()
    if categoryId
      category = currentTaskList.categories.find (c) ->
        c.id == categoryId
      url = Routes.api_task_item_path(categoryId)
    else
      url = Routes.api_task_items_path()
    $.ajax(
      url: url
      type: if categoryId then 'PUT' else 'POST'
      dataType: "json"
      data:
        task_item:
          title: title
          task_list_id: currentTaskList.id
    ).then (response) ->
      if categoryId
        category.title = title
      else
        category = response
        currentTaskList.categories.push(response)
        renderCategoryForm(category)
      renderCategory(category, !categoryId)

  deleteCategory = (id, categoryId) ->
    taskList = taskLists.find (list) ->
      list.id == id
    $.ajax(
      url: Routes.api_task_item_path(categoryId)
      dataType: "json"
      type: "DELETE"
    ).then (response) ->
      findCategoryElement(categoryId).remove()
      taskList.categories = taskList.categories.filter (c) ->
        c.id != categoryId

  deleteItem = (id, categoryId, itemId) ->
    taskList = taskLists.find (list) ->
      list.id == id
    category = taskList.categories.find (c) ->
      c.id == categoryId
    $.ajax(
      url: Routes.api_task_item_path(categoryId)
      dataType: "json"
      type: "DELETE"
    ).then (response) ->
      $(".checklist-item[data-id='#{itemId}']").remove()
      category.items = category.items.filter (i) ->
        i.id != itemId
      renderCategory(category, false)

  renderItem = (item) ->
    prepareItem(item)
    $html = $(Mustache.render($categoryItemTemplate, item))
    $html.find('.x-editable').editable(xeditableOptions)
    $categoryModal.find(".items-listing").append($html)

  addItem = (id, categoryId) ->
    title = $("#category-item-name").val()
    return if !title
    $.ajax(
      url: Routes.api_task_items_path()
      dataType: "json"
      type: "POST"
      data:
        task_item:
          task_list_id: id
          category_id: categoryId
          title: title
    ).then (response) ->
      taskList = taskLists.find (list) ->
        list.id == id
      category = taskList.categories.find (c) ->
        c.id == categoryId
      category.items.push(response)
      renderItem(response)
      renderCategory(category, false)
      $("#category-item-name").val("").focus()

  renderTaskLists = (lists) ->
    for list in lists
      list.assignable_roles = list.task_list_roles.filter((role) ->
        role.scope_type == "assignable"
      ).map((role) ->
        role.department_name + " " + role.role_name
      ).join(", ")
      list.reviewable_roles = list.task_list_roles.filter((role) ->
        role.scope_type == "reviewable"
      ).map((role) ->
        role.department_name + " " + role.role_name
      ).join(", ")
      html = Mustache.render($taskListTemplate, list,
        category: $categoryTemplate
      )
      $container.append(html)
    updatePanelClasses()

  updatePanelClasses = ->
    for list, index in taskLists
      $panel = findTaskListElement(list.id)
      $panel.attr('class', "panel task-list #{PANEL_CLASSES[index % 6]}")

  loadTaskLists = ->
    $.ajax(
      url: Routes.all_api_task_lists_path()
      type: "GET"
      dataType: "json"
    ).done (response) ->
      taskLists = response
      renderTaskLists(taskLists)

  loadTaskLists()

  $(document).on "dialog.confirmed", ".checklist-delete", (e) ->
    e.preventDefault()
    id = findTaskListId(@)
    deleteTaskList(id)

  $(document).on "click", ".add-category", (e) ->
    e.preventDefault()
    id = findTaskListId(@)
    showCategoryModal(id)

  $(document).on "click", ".category-name", (e) ->
    e.preventDefault()
    id = findTaskListId(@)
    categoryId = findCategoryId(@)
    showCategoryModal(id, categoryId)

  $(document).on "click", "#category-form-submit", (e) ->
    e.preventDefault()
    categoryId = $(@).parents("form").data("id")
    saveCategory(categoryId)

  $(document).on "click", ".checklist-name", (e) ->
    e.preventDefault()
    id = findTaskListId(@)
    window.location = Routes.edit_task_list_path(id)

  $(document).on "dialog.confirmed", ".category-delete", (e) ->
    e.preventDefault()
    id = findTaskListId(@)
    categoryId = findCategoryId(@)
    deleteCategory(id, categoryId)

  $(document).on "dialog.confirmed", ".checklist-item-delete", (e) ->
    e.preventDefault()
    id = currentTaskList.id
    categoryId = $(@).parents("form").data("id")
    itemId = $(@).parents(".checklist-item").data("id")
    deleteItem(id, categoryId, itemId)

  $(document).on "click", ".add-item", (e) ->
    e.preventDefault()
    id = currentTaskList.id
    categoryId = $(@).parents("form").data("id")
    addItem(id, categoryId)

  $(document).on 'keypress', '#category-item-name', (e) ->
    if e.which == 13
      id = currentTaskList.id
      categoryId = $(@).parents("form").data("id")
      addItem(id, categoryId)

$(document).ready(checklistSetupPage)