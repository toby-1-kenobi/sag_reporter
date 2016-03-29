# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Hide all the states in the dropdown, and then unhide the ones that
# belong in the selected zone(s)
showStates = ->
  if $("#user-zone-dropdown .zone-option input:checked").length > 0
    # Reveal the state selector if zones are selected
    $('[data-activates="user-geo_states-dropdown"]').slideDown()
  else
  	# Hide the state selector if no zones are selected
    $('[data-activates="user-geo_states-dropdown"]').slideUp()
  return

# Show only the languages that are in the selected geo_state(s)
# This applies to  the "mother tongue" selector
# It is assumed the HTML for the MT selector is modified by the Materialize framework
setLanguageOptions = ->
  selectedStates = new Array()
  # first hide all the languages
  $('.mother-tongue-select li').addClass 'hide'
  # get the ids of all selected states
  $('#user-geo_states-dropdown .geo_states-option input:checked').each ->
    stateOptionId_a = $(this).parent().attr("id").split('-')
    selectedStates.push(stateOptionId_a[stateOptionId_a.length - 1])
    return
  $('.speaks-option').each ->
    thisOption = $(this)
    # The data attribute is a comma-seperated list of the ids of all states this language is in
    jQuery.each thisOption.attr('data').split(','), (index, value) ->
      if jQuery.inArray(value, selectedStates) >= 0
        # we found a language in the "speaks" option that belongs in the states
        # now we need to unhide the corresponding language in the mother-tongue selector
        # find it by language name
        $('.mother-tongue-select li span').filter( ->
          return $(this).text() == thisOption.find('label').text()
        ).parent('li').removeClass 'hide'
      return
    return
  # hidden languages should not be selected
  $('.mother-tongue-select li.hide').removeClass 'active'
  # if there are no selected languages the displayed selection should be blank
  if $('.mother-tongue-select li.active').length == 0
  	$('.mother-tongue-select input.select-dropdown').attr('value', '')
  # if there are no states selected then hide the language selection boxes
  if $("#user-geo_states-dropdown .geo_states-option input:checked").length > 0
    $('[data-activates="user-speaks-dropdown"]').slideDown()
    $('.mother-tongue-select').parent().slideDown()
  else
    $('[data-activates="user-speaks-dropdown"]').slideUp()
    $('.mother-tongue-select').parent().slideUp()
  return

$(document).on "page:change", ->
  $('select').material_select()

  showStates()
  setLanguageOptions()

  $("#user-zone-dropdown .zone-option input").change showStates
  $("#user-geo_states-dropdown .geo_states-option input").change setLanguageOptions

  return