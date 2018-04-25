# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

personCount = 0

addField = ->
  personCount += 1
  newField = $('<input type="text" name="person__' + personCount + '" value="" data-autocomplete="/events/autocomplete_person_name" />')
  $(this).off 'keypress', addField
  newField.on 'keypress', addField
  newField.hide()
  newField.addClass('contributer-input')
  $(this).after newField
  newField.slideDown()
  return

$(document).on "ready page:change", ->
  $('.contributers input:last').on 'keypress', addField
  #$('#language-input .select-dropdown li').addClass 'filterable-item'
  return