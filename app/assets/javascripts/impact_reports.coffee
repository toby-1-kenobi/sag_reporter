# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

filter_impact_reports = ->

  # mark the cards that aren't in the selected geo_state
  state_id = $('#geo_state_id').val()
  $('.card.impact_report').addClass 'wrong-state'
  $('.card.impact_report[data-geo-state="' + state_id + '"]').removeClass 'wrong-state'

  # mark the cards that aren't in one of the selected languages.
  $('.card.impact_report').addClass 'wrong-language'
  $('#language-selected-dropdown input:checkbox:checked').each ->
    lang_id = $(this).attr('id').split('_').pop()
    $('.card.impact_report[data-language~="' + lang_id + '"]').removeClass 'wrong-language'
    return

  # Hide the marked cards
  $('.card.impact_report').removeClass 'hide'
  $('.card.impact_report.wrong-state').addClass 'hide'
  $('.card.impact_report.wrong-language').addClass 'hide'

  return

$(document).ready ->

  filter_impact_reports()
  
  $('.outcome-area-input select').change ->
  	if $(this).val().length > 0
  	  pm_input = $(this).parents('.report-tagging').find('.progress-marker-input')
  	  oa_id = $(this).val()
  	  pm_input.find('select').html($('#progress-markers-data #' + oa_id + '-data').html()).material_select()
  	  pm_input.hide().removeClass('hide').slideDown(350)
  	return

  $('.progress-marker-input select').change ->
  	marker_id = $(this).val()
  	if marker_id.length > 0
  	  report_id = $(this).parents('.report-tagging').find('.report').attr('id').split('-').pop()
  	  $.post report_id + '/tag_update', { _method: "patch", pm_id: marker_id }, (data) ->
  	    if data.indexOf "success" >= 0
  	  	  $('#report-' + report_id).parents('.report-tagging').addClass('completed').fadeOut()
  	    return
  	return

  $('.card.impact_report').click ->
    $('.card.impact_report.selected').removeClass('z-depth-1 selected').addClass('z-depth-3')
    $(this).removeClass('z-depth-3').addClass('z-depth-1 selected')
    return

  $('#geo_state_id').on 'change', filter_impact_reports
  $('#language-selected-dropdown input').on 'change', filter_impact_reports
  
  return