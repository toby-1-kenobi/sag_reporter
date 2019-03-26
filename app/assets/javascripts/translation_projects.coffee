# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "ready page:change", ->

  $('.translation-project-controls [data-auto-update]').on 'input', ->
    $(this).addClass('dirty')
    return

  $('.translation-project-controls [data-auto-update]').on 'change', ->
    field = $(this).data('field')
    data = {translation_project: {}}
    data['translation_project'][field] = $(this).val()
    url = $(this).closest('.translation-project-controls').data('update-path')
    $.ajax(
      url,
      method: "PATCH",
      data: data
    )
    return

  return