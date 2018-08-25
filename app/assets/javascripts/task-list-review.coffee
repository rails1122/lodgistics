$(document).on "click", ".timeline-content .panel", (e) ->
  e.preventDefault()
  listId = $(@).data("id")
  recordId = $(@).data("record-id")
  window.location = Routes.task_list_path(listId, record_id: recordId)