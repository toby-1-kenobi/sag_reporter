# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
	
$(document).ready ->

  $('.activity-level-select').on 'change', ->
    spreadText = $('#pm-data #spread-' + $(this).val()).attr('label')
    $(this).parents('.progress-marker').find('.spreadness-text').html(spreadText)
    $(this).parents('.progress-marker').find('input:checkbox[name^="marker_complete"]').prop 'checked', true
    return

  $('.activity-level-select').trigger 'change'
  $('input:checkbox[name^="marker_complete"]').prop 'checked', false

  $('.month-select select').on 'change', ->
    month = $(this).val()
    $('.report').show().addClass('showing')
    $('.report').filter((index) ->
      reportDate = new Date($(this).attr('data-date'))
      return reportDate.getMonth() + 1 != parseInt(month)
    ).hide().removeClass('showing')
    $('.progress-marker').each (index, element) ->
      $(this).find('.report-count').html($(this).find('.report.showing').length)
      return
    return

  $('.month-select select').trigger 'change'
  $('.filter-trigger').trigger 'change'

  return