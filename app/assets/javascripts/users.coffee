# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Hide all the states in the dropdown, and then unhide the ones that
# belong in the selected zone(s)
showStates = ->
  $("#user-geo_states-dropdown .geo_states-option").addClass("hide")
  if $("#user-zone-dropdown .zone-option input:checked").length > 0
    $("#user-zone-dropdown .zone-option input:checked").each ->
      zone_id = $(this).parent().attr("data")
      $("#user-geo_states-dropdown .geo_states-option[data='" + zone_id + "']").removeClass("hide")
      return
    # Reveal the state selector if zones are selected
    $('[data-activates="user-geo_states-dropdown"]').slideDown()
  else
  	# Hide the state selector if no zones are selected
    $('[data-activates="user-geo_states-dropdown"]').slideUp()
  # hidden states should not be selected
  $("#user-geo_states-dropdown .geo_states-option.hide input:checked").prop('checked', false)
  return

# Show only the languages that are in the selected geo_state(s)
# This applies to both the "able to speak" dropdown and the "mother tongue" selector
# It is assumed the HTML for the MT selector is modified by the Materialize framework
setLanguageOptions = ->
  selectedStates = new Array()
  # first hide all the languages
  $('.speaks-option').addClass 'hide'
  $('.mother-tongue-select li').addClass 'hide'
  # get the ids of all selected states
  $('#user-geo_states-dropdown .geo_states-option input:checked').each ->
    stateOptionId_a = $(this).parent().attr("id").split('-')
    selectedStates.push(stateOptionId_a[stateOptionId_a.length - 1])
    return
  $('.speaks-option').each ->
    thisOption = $(this)
    # The data attribute is a comma-seperated list of the ids of all states this language is in
    jQuery.each $(this).attr('data').split(','), (index, value) ->
      if jQuery.inArray(value, selectedStates) >= 0
        thisOption.removeClass('hide')
        # we found a language in the "speaks" option that belongs in the states
        # now we need to unhide the corresponding language in the mother-tongue selector
        # find it by language name
        $('.mother-tongue-select li span').filter( ->
          return $(this).text() == thisOption.find('label').text()
        ).parent('li').removeClass 'hide'
      return
    return
  # hidden languages should not be selected in the mother-tongue selector
  $('.mother-tongue-select li.hide').removeClass 'active'
  # if there are no selected languages the displayed selection should be blank
  if $('.mother-tongue-select li.active').length == 0
  	$('.mother-tongue-select input.select-dropdown').attr('value', '')
  return

$(document).ready ->
  $('select').material_select()

  showStates()
  setLanguageOptions()

  $("#user-zone-dropdown .zone-option input").change showStates
  $("#user-geo_states-dropdown .geo_states-option input").change setLanguageOptions

  return