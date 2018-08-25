window.isTouchDevice = ->
  $('html').hasClass('touch')

window.updatePropertyTimeZone = (zone) ->
  $("#property-time").attr("data-timezone", zone)

window.getPropertyTimeZone = ->
  $("#property-time").attr("data-timezone")

resizeMenuAndWindowSize = ->
  windowHeight = $(window).height()
  menuHeight = $(".documentation").prev().offset().top + 42
  if windowHeight - menuHeight - 120 > 0
    $(".documentation").addClass("to-bottom")
  else
    $(".documentation").removeClass("to-bottom")

$(window).resize $.debounce(100, resizeMenuAndWindowSize)

$(document).on "hidden.bs.collapse shown.bs.collapse", ".topmenu a[data-toggle='submenu'], .topmenu .collapse", resizeMenuAndWindowSize

$(document).ready ->
  updateTime = ->
    $("#property-time").text(moment().tz(window.getPropertyTimeZone()).format("hh:mm A"))

  setInterval(updateTime, 1000)