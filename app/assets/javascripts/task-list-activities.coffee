reviewActivitiesPage = ->
  return unless $('body').hasClass('task-list-activities-page')

  activities = []
  loading = false
  activityTemplate = $('#task-list-activity-template').html()
  nameTemplate = $('#task-list-name-template').html()
  currentUserId = parseInt($("body").data("user-id").split("_")[1])

  containerId = "#task-list-activities-content"
  $container = $(containerId)
  $loadMore = $(".load-more")
  $noMore = $(".no-more")
  $spinner = $(".indicator")

  $spinner.hide()
  $loadMore.hide()
  $noMore.hide()

  renderActivities = (lists) ->
    for activity in lists
      html = Mustache.render(activityTemplate, activity,
        name: nameTemplate
      )
      $container.append(html)

  parseActivities = () ->
    for activity, index in activities
      activity.left = (index % 2) == 0
      for user in ['finished_by', 'reviewed_by']
        activity[user].selfCompleted = true if activity[user] && activity[user].id == currentUserId

  loadActivities = ->
    loading = true
    $spinner.show()
    params =
      limit: 10
    lastActivity = activities[activities.length - 1]
    params.finished_after = lastActivity.finished_at if lastActivity
    $.ajax(
      url: Routes.activities_api_task_lists_path()
      type: "GET"
      dataType: "json"
      data: params
    ).done((response) ->
      if response.length == 10
        $loadMore.show()
        $noMore.hide()
      else
        $loadMore.hide()
        $noMore.show()
      activities = activities.concat(response)
      parseActivities()
      renderActivities(response)
    ).complete(->
      $spinner.hide()
      loading = false
    )

  loadActivities()

  $(document).on "click", ".load-more > a", (e) ->
    e.preventDefault()
    return if loading
    loadActivities()

$(document).ready(reviewActivitiesPage)