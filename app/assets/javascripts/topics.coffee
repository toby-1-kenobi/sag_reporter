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
  	return

  $('#outcome-area-select .card').hover (->
    $(this).addClass 'z-depth-3'
    $(this).css 'top', '-5px'
    return
  ), ->
    $(this).removeClass 'z-depth-3'
    $(this).css 'top', '0'
    return


  return