# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  
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
  
  return