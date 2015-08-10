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
decisionCount = 0

addTextArea = ->
  textAreaCount += 1
  newTextArea = $('<div class="row response-input">
              	<div class="input-field col s6">
              	  <textarea class="materialize-textarea" id="response"></textarea>
                  <label for="response">Something else that was said</label>
              	</div>
              	<div class="col s6">
              	  <div>
          	        <input type="radio" name="res_' + textAreaCount + '" id="res_impact_' + textAreaCount + '" value="impact" />
          	        <label for="res_impact_' + textAreaCount + '">This is an impact</label>
          	      </div>
          	      <div>
          	        <input type="radio" name="res_' + textAreaCount + '" id="res_hope_' + textAreaCount + '" value="hope" />
          	        <label for="res_plan_' + textAreaCount + '">We hope this will happen in the future</label>
          	      </div>
              	</div>
              </div>')
  $(this).unbind()
  newTextArea.find('textarea').keypress addTextArea
  $(this).parents('.response-input').after newTextArea
  return

addNewDecision = ->
  decisionCount += 1
  newDecision = $('<div class="row decision-response-input">
              <div class="input-field col s6">
                <textarea name="decision-response_' + decisionCount + '" id="decision-response_' + decisionCount + '" class="materialize-textarea">
</textarea>
                <label for="decision-response">What action must be taken?</label>
              </div>
              <div class="input-field col s6">
                <input type="text" name="person-responsible_' + decisionCount + '" id="person-responsible_' + decisionCount + '" value="" data-autocomplete="/events/autocomplete_person_name" />
                <label for="person-responsible_' + decisionCount + '">The person responsible</label>
              </div>
            </div>')
  $(this).unbind()
  newDecision.find('#decision-response_' + decisionCount).keypress addNewDecision
  $(this).parents('.decision-response-input').after newDecision
  return

$(document).ready ->

  $('.datepicker').pickadate ->
    selectMonths: true, 
    selectYears: 3

  $('.people-increase input:last').on 'keypress', addField
  $('.response-input textarea').keypress addTextArea
  $('#decision-response').keypress addNewDecision

  $('.yes-no-question input:radio').change ->
    answer = $('label[for=\'' + $(this).attr('id') + '\']').text()
    if answer == "Yes"
      $(this).parents('.yes-no-question').find('.yes-response').removeClass('hide')
    if answer == "No"
      $(this).parents('.yes-no-question').find('.yes-response').addClass('hide')
    return

  return