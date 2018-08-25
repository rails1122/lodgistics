checklistFormPage = ->
  return unless $('body').hasClass('task-list-form')

  addRole = (type, $element) ->
    $roles = $element.next()
    $role = $roles.find(".permission-role").last()
    $new = $role.clone()
    $new.find("select.checklist-selector").val('')
    $new.find(".permission-id").val('')
    $new.find(".destroy-role").val(false)
    enableFields($new)
    $new.find(".btn-remove").removeClass("hidden")
    $new.find(".btn-add").addClass("hidden")
    $new.find("[data-toggle=\"tooltip\"]").tooltip()
    $new.find("input, select").each ->
      name = $(@).prop('name')
      number = parseInt(name.match(/\d/g)[0])
      $(@).prop('name', name.replace(/(\d)/g, number + 1))
    $roles.append($new)

  disableFields = ($role) ->
    $role.find("select.checklist-selector").attr("disabled", "disabled")

  enableFields = ($role) ->
    $role.find("select.checklist-selector").removeAttr("disabled")

  $("#checklist-attachment").on "change", (e) ->
    file = e.target
    if file.files and file.files[0]
      $("#checklist-attachment-name").val(file.files[0].name)
    else
      $("#checklist-attachment-name").val('')

  $(document).on "click", ".btn-remove", (e) ->
    e.preventDefault()
    $this = $(@)
    $role = $this.parents(".permission-role")
    $this.toggleClass("hidden")
    $role.find(".btn-add").toggleClass("hidden")
    $role.find(".destroy-role").val(true)
    disableFields($role)

  $(document).on "click", ".btn-add", (e) ->
    e.preventDefault()
    $this = $(@)
    $role = $this.parents(".permission-role")
    $this.toggleClass("hidden")
    $role.find(".btn-remove").toggleClass("hidden")
    $role.find(".destroy-role").val(false)
    enableFields($role)

  $(".add-assignable-role").on "click", (e) ->
    e.preventDefault()
    $this = $(@)
    addRole('assignable', $this)

  $(".add-reviewable-role").on "click", (e) ->
    e.preventDefault()
    $this = $(@)
    addRole('reviewable', $this)

$(document).ready(checklistFormPage)