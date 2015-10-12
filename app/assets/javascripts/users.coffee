# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

showStates = ->
  $("#user-geo_states-dropdown .geo_states-option").addClass("hide")
  if $("#user-zone-dropdown .zone-option input:checked").length > 0
    $("#user-zone-dropdown .zone-option input:checked").each ->
      zone_id = $(this).parent().attr("data")
      $("#user-geo_states-dropdown .geo_states-option[data='" + zone_id + "']").removeClass("hide")
      return
    $('[data-activates="user-geo_states-dropdown"]').slideDown()
  else
    $('[data-activates="user-geo_states-dropdown"]').slideUp()
  return

setLanguageOptions = ->
  selectedStates = new Array()
  $('.speaks-option').addClass 'hide'
  $('#user-geo_states-dropdown .geo_states-option input:checked').each ->
    stateOptionId_a = $(this).parent().attr("id").split('-')
    selectedStates.push(stateOptionId_a[stateOptionId_a.length - 1])
    return
  $('.speaks-option').each ->
    thisOption = $(this)
    jQuery.each $(this).attr('data').split(','), (index, value) ->
      if jQuery.inArray(value, selectedStates) >= 0
        thisOption.removeClass('hide')
      return
    return
  return

$(document).ready ->
  $('select').material_select()

  showStates()
  setLanguageOptions()

  $("#user-zone-dropdown .zone-option input").change showStates
  $("#user-geo_states-dropdown .geo_states-option input").change setLanguageOptions

  return