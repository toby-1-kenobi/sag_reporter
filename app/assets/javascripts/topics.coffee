# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
	
$(document).ready ->
  
  $('#outcome-area-select .card').on 'click', ->
  	$(this).addClass('chosen').unbind().removeClass 'z-depth-3'
  	oa_id = $(this).attr('id').split('-').pop()
  	$('#language-select').html($('#language-select').html().replace(/__topic_id/g, oa_id))
  	new_height = $('.chosen').outerHeight true
  	distance = 0
  	$('.chosen').prevAll().each ->
  	  distance += $(this).outerHeight true
  	$(this).siblings().fadeOut 800
  	$(this).animate {top: (distance * -1) + 'px'}, 800
  	$(this).parent().animate {height: new_height}, 800, ->
  	  $('.chosen').css 'top', '0'
  	  $('#language-select').slideDown 'slow'
  	  return
    $('.collapsible').collapsible()
  	return

  $('#outcome-area-select .card').hover (->
    $(this).addClass 'z-depth-3'
    $(this).css 'top', '-5px'
    return
  ), ->
    $(this).removeClass 'z-depth-3'
    $(this).css 'top', '0'
    return

  $('.activity-level-select').on 'change', ->
    spreadText = $('#pm-data #spread-' + $(this).val()).attr('label')
    $(this).parents('.progress-marker').find('.spreadness-text').html(spreadText)
    return

  $('.activity-level-select').trigger 'change'

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

  return