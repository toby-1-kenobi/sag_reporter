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
  $(this).after newField
  newField.slideDown()
  return

$(document).ready ->
  $('.contributers input:last').on 'keypress', addField
  return