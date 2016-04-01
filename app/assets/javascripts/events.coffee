# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

personCount = 0
textAreaCount = 0
decisionCount = 0

addField = ->
  personCount += 1
  newField = $('<input type="text" name="person__' + personCount + '" value="" data-autocomplete="/events/autocomplete_person_name" />')
  $(this).off 'keypress', addField
  newField.on 'keypress', addField
  $(this).after newField
  return

addInputRow = ->
  textAreaCount += 1
  newInputRow = $('<div class="row response-input row__' + textAreaCount + '"></div>')
  newInputRow.html($(this).parents('.response-input').html().replace(/__\d+/g, '__' + textAreaCount))
  $(this).off 'keypress', addInputRow
  newInputRow.find('textarea').on 'keypress', addInputRow
  newInputRow.find('.dropdown-content').removeAttr('style')
  newInputRow.hide()
  $(this).parents('.response-input').after newInputRow
  newInputRow.slideDown()
  newInputRow.find('.dropdown-button').dropdown
    inDuration: 300
    outDuration: 225
    constrain_width: true
    hover: true
    gutter: 0
    belowOrigin: false
  return

addNewDecision = ->
  decisionCount += 1
  newDecision = $('<div class="row decision-response-input row__' + decisionCount + '"></div>')
  newDecision.html($(this).parents('.decision-response-input').html().replace(/__\d+/g, '__' + decisionCount))
  $(this).off 'keypress', addNewDecision
  newDecision.find('textarea').on 'keypress', addNewDecision
  $(this).parents('.decision-response-input').after newDecision
  return

updateDistrictData = ->
  geo_state_id = $('#event_geo_state_id').val()
  old_url = $('#district-autocomplete input').attr('data-autocomplete') 
  url = old_url.replace(/\d+/, geo_state_id)
  if old_url != url
    $('#sub-district-autocomplete').hide()
    $('#sub-district-autocomplete input').val('')
    $('#village-input').hide()
    $('#district-autocomplete input').attr('data-autocomplete', url)
    $('#district-autocomplete input').val('')
  return

$(document).on "page:change", ->

  $('.datepicker').pickadate ->
    selectMonths: true, 
    selectYears: 3

  $('#event_geo_state_id').on 'change', updateDistrictData
  $('#district-autocomplete input').on 'railsAutocomplete.select', (event, data) ->
    old_url = $('#sub-district-autocomplete input').attr('data-autocomplete')
    url = old_url.replace(/\d+/, data.item.id)
    if old_url != url
      $('#village-input').hide()
      $('#sub-district-autocomplete input').attr('data-autocomplete', url)
      $('#sub-district-autocomplete input').val('')
      $('#sub-district-autocomplete').slideDown 400, ->
        $('#sub-district-autocomplete input').focus()
        return
    return 
  $('#sub-district-autocomplete input').on 'railsAutocomplete.select', (event, data) ->
    $('#village-input').slideDown 400, ->
      $('#village-input input').focus()
      return
    return

  $('#add-action-point').on 'click', ->
    fields = $('#action_points_fields_template').clone()
    new_id = new Date().getTime()
    regexp = new RegExp('00000', 'g')
    $('#add-action-point').before(fields.html().replace(regexp, new_id))
    return

  $('#add-event-report').on 'click', ->
    fields = $('#reports_fields_template').clone()
    new_id = new Date().getTime()
    regexp = new RegExp('00000', 'g')
    $('#add-event-report').before(fields.html().replace(regexp, new_id))
    $('.dropdown-button').dropdown({ hover: true })
    return

  $('.people-increase input:last').on 'keypress', addField
  $('.response-input textarea').on 'keypress', addInputRow
  $('.decision-response-input textarea').on 'keypress', addNewDecision

  $('.yes-no-question input:radio').change ->
    answer = $(this).val()
    if answer == "yes"
      $(this).parents('.yes-no-question').find('.yes-response').hide().removeClass('hide').slideDown()
    if answer == "no"
      $(this).parents('.yes-no-question').find('.yes-response').slideUp()
    return

  return