# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

  $('.get-chart-button').click()

  $('#jp-fetch-trigger').click()

  $('.editable').hover (->
    $(this).find('.edit-icon').removeClass('hide')
    return
  ), ->
    $(this).find('.edit-icon').addClass('hide')
    return

  openFinishLineDialog = (number, churchEngagement) ->
    name = $("#finish-line-marker-#{number}-name").html()
    description = $("#finish-line-marker-#{number}-description").html()
    dialog = $('#finish-line-dialog')
    if churchEngagement
      dialog.find('.finish-line-progress-options-ce').removeClass('hide')
      dialog.find('.finish-line-progress-options').addClass('hide')
    else
      dialog.find('.finish-line-progress-options-ce').addClass('hide')
      dialog.find('.finish-line-progress-options').removeClass('hide')
    dialog.find('.mdl-dialog__title').html(name)
    dialog.find('.description').html(description)
    # need to put the marker number in the link hrefs
    dialog.find('a.progress-link').each ->
      $(this).attr('href', $(this).attr('href').replace(/set_finish_line_progress\/.*\//, "set_finish_line_progress/#{number}/"))
    dialog.get(0).showModal()
    return

  $('.editable').on 'click', ->
    id = this.id
    if $(this).hasClass('finish-line-progress-status')
      number = id.substring(id.lastIndexOf('-') + 1)
      openFinishLineDialog(number, $(this).hasClass('church-engagement'))
    else
      $("dialog[data-for=\"#{id}\"]").get(0).showModal()
    return

  $('.finish-line-switch').on 'click', ->
    id = this.id
    number = id.substring(id.lastIndexOf('-') + 1)
    openFinishLineDialog(number, $(this).hasClass('church-engagement'))
    # prevent the switch from switching
    return false

  $('.add-engaged-org-button').on 'click', ->
    $('#add-engaged-org-dialog').get(0).showModal()
    return

  $('.add-translating-org-button').on 'click', ->
    $('#add-translating-org-dialog').get(0).showModal()
    return

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