# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

showStates = ->
  $("#user-geo_states-dropdown .geo_states-option").addClass("hide");
  if $("#user-zone-dropdown .zone-option input:checked").length > 0
  	$("#user-zone-dropdown .zone-option input:checked").each ->
  	  zone_id = $(this).parent().attr("data")
  	  $("#user-geo_states-dropdown .geo_states-option[data='" + zone_id + "']").removeClass("hide")
  	  return
  	$('[data-activates="user-geo_states-dropdown"]').slideDown();
  else
  	$('[data-activates="user-geo_states-dropdown"]').slideUp();
  return

$(document).ready ->
  # the "href" attribute of .modal-trigger must specify the modal ID that wants to be triggered
  $('select').material_select()

  showStates()

  $("#user-zone-dropdown .zone-option input").change showStates

  return