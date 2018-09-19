$(document).on "ready page:change", ->
  $('#new-project-list-item').find('input').on 'change', ->
    $(this).closest('form').submit()

