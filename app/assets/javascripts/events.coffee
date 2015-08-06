# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

addField = ->
  newField = $('<input type="text" name="people" value="" data-autocomplete="/events/autocomplete_person_name" />')
  $(this).off 'keypress', addField
  newField.on 'keypress', addField
  $(this).after newField
  return

textAreaCount = 0

addTextArea = ->
  textAreaCount += 1
  newTextArea = $('<div class="row response-input">
              	<div class="col s6">
              	  <textarea class="materialize-textarea"></textarea>
              	</div>
              	<div class="col s6">
          	      <input type="radio" name="res_' + textAreaCount + '" id="res_impact_' + textAreaCount + '" value="impact" />
          	      <label for="res_impact_' + textAreaCount + '">This has already happened</label>
          	      <input type="radio" name="res_' + textAreaCount + '" id="res_hope_' + textAreaCount + '" value="hope" />
          	      <label for="res_hope_' + textAreaCount + '">We hope this will happen in the future</label>
          	      <input type="radio" name="res_' + textAreaCount + '" id="res_challenge_' + textAreaCount + '" value="challenge" />
          	      <label for="res_challenge_' + textAreaCount + '">This is a challenge</label>
              	</div>
              </div>')
  $(this).unbind()
  newTextArea.find('textarea').keypress addTextArea
  $(this).parents('.response-input').after newTextArea
  return

$(document).ready ->

  $('.datepicker').pickadate ->
    selectMonths: true, 
    selectYears: 3

  $('.people-increase input:last').on 'keypress', addField
  $('.yes-response textarea:last-of-type').keypress addTextArea

  $('.yes-no-question input:radio').change ->
    answer = $('label[for=\'' + $(this).attr('id') + '\']').text()
    if answer == "Yes"
      $(this).parents('.yes-no-question').find('.yes-response').removeClass('hide')
    if answer == "No"
      $(this).parents('.yes-no-question').find('.yes-response').addClass('hide')
    return

  return