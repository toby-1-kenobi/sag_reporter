# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

  $('.outcome-progress-cell .get-chart-button').click()

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

  $('.language-filter-controls .over').on 'click', ->
    # get the thing that will slide out from under
    under = $(this).nextAll('.under:first')
    if ($(under).is(":visible"))
      under.removeClass('mdl-shadow--4dp')
      under.children('.shadow-clipper').fadeOut 200, ->
        under.slideUp(300)
    else
      under.slideDown 300, ->
        under.addClass('mdl-shadow--4dp')
        under.children('.shadow-clipper').fadeIn(200)

  return