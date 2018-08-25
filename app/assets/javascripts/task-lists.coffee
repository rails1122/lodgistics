myChecklistPage = ->
  return unless $('body').hasClass('task-list-page')

  taskLists = []
  taskListTemplate = $('#task-list-template').html()
  taskListActivityTemplate = $('#task-list-activity-template').html()
  taskListNameTemplate = $('#task-list-name-template').html()
  currentUserId = parseInt($("body").data("user-id").split("_")[1])

  containerId = "#task-list-content"
  $container = $(containerId)

  renderTaskLists = (lists) ->
    for list, index in lists
      list.index = index + 1
      html = Mustache.render(taskListTemplate, list,
        activity: taskListActivityTemplate,
        name: taskListNameTemplate
      )
      $container.append(html)
      $container.find(".collapse").collapse().collapse("hide")

  goToTaskList = (listId, recordId) ->
    window.location = Routes.task_list_path(listId, record_id: recordId)

  startTaskList = (listId) ->
    $.ajax(
      url: Routes.start_resume_api_task_list_path(listId)
      type: "POST"
      dataType: "json"
    ).done (taskListRecord) ->
      goToTaskList(listId, taskListRecord.id)

  startResumeTaskList = (listId) ->
    list = taskLists.find((list) -> list.id == listId)
    recordId = list.task_list_record_id
    if recordId
      goToTaskList(listId, recordId)
    else
      startTaskList(listId)

  parseActivities = (activities) ->
    for activity, index in activities
      activity.left = (index % 2) == 0
      taskListId = activity.task_list.id
      for user in ['finished_by', 'reviewed_by']
        activity[user].selfCompleted = true if activity[user] && activity[user].id == currentUserId

      taskList = taskLists.find (l) ->
        l.id == taskListId
      if taskList
        taskList.lastActivity = activity unless taskList.lastActivity
        taskList.activities ||= []
        taskList.activities.push(activity)

  loadActivities = ->
    $.ajax(
      url: Routes.activities_api_task_lists_path()
      type: "GET"
      dataType: "json"
    ).done (response) ->
      parseActivities(response)
      renderTaskLists(taskLists)

  loadTaskLists = ->
    $.ajax(
      url: Routes.api_task_lists_path()
      type: "GET"
      dataType: "json"
    ).done (response) ->
      taskLists = response
      loadActivities()

  $(document).on "click", "#{containerId} .btn-start-resume", (e) ->
    e.preventDefault();
    listId = $(@).parents(".task-list").data("id")
    startResumeTaskList(listId)

  loadTaskLists()

$(document).ready(myChecklistPage)

