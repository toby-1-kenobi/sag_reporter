# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

  $('#jp-fetch-trigger').click()

  prev_adjust = ''

  $('.colour-darkness-range').on 'change', ->
  	value = $(this).val()
  	if value < 0 
  	  colour_adjust = 'lighten-' + (value * -1)
  	else
  	  if value > 0
  	    colour_adjust = 'darken-' + $(this).val()
  	  else
  	    colour_adjust = ''
  	if prev_adjust != ''
  	  $(this).parents('#colour_picker').find('td').removeClass(prev_adjust)
  	if colour_adjust != ''
  	  $(this).parents('#colour_picker').find('td').addClass(colour_adjust)
  	prev_adjust = colour_adjust
  	return

  return