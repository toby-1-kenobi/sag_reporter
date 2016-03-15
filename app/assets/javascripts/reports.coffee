# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

addImageInput = ->
  $(this).off 'change', addImageInput
  imageListUpdate()
  $(this).on 'change', imageListUpdate
  new_input = $(this).clone()
  new_name = new_input.attr('name').replace(/\[\d*\]/g, (x) ->
    '[' + (parseInt(x.slice(1, -1)) + 1) + ']'
  )
  new_input.attr('name', new_name)
  new_id = new_input.attr('id').replace(/_\d*_/g, (x) ->
    '_' + (parseInt(x.slice(1, -1)) + 1) + '_'
  )
  new_input.attr('id', new_id)
  new_input.on 'change', addImageInput
  new_input.insertAfter($(this))
  $(this).siblings('label').attr('for', new_id)
  return

imageListUpdate = ->
  list = ""
  $('.picture-input input').each ->
    if typeof this.files[0] != 'undefined'
      size_in_megabytes = this.files[0].size/1024/1024;
      if size_in_megabytes > 5
        alert 'Maximum file size is 5MB. Please choose a smaller file.'
    filename = $(this).val().split('\\').pop()
    if filename.length > 0
      list += '<li class="collection-item">' +
        '<label for="' + $(this).attr('id') + '" class="black-text">' +
        $(this).val().split('\\').pop() +
        '</label></li>'
    return
  $('#file-list').html(list)

$(document).on "page:change", ->

  if $('.report-type input:checkbox:checked').length == 0
    $('#report_impact_report').prop('checked', true)

  $('#show_archived_reports').change ->
    if @checked
      $('.report.archived').removeClass 'hide'
      $('.report.too_old').addClass 'hide'
    else
      $('.report.archived').addClass 'hide'
    return

  $('#date-range').change ->
    cutoff = undefined
    now = new Date()
    if $(this).val() == '0'
      $('#date-range-value').text 'Show all'
    else if $(this).val() == '1'
      $('#date-range-value').text 'Since one year ago'
      cutoff = now - 1000 * 60 * 60 * 24 * 365
    else if $(this).val() == '2'
      $('#date-range-value').text 'Since one month ago'
      cutoff = now - 1000 * 60 * 60 * 24 * 31
    else if $(this).val() == '3'
      $('#date-range-value').text 'Since one week ago'
      cutoff = now - 1000 * 60 * 60 * 24 *  7
    $('.report.too_old').removeClass 'hide'
    $('.report').removeClass 'too_old'
    if typeof cutoff	 != 'undefined'
      $('.report').filter(->
        date = new Date($(this).attr('data-date'))
        date < cutoff
      ).addClass 'too_old hide'
    if !$('#show_archived_reports').checked
      $('.report.archived').addClass 'hide'
    return

  $('.picture-input input').on 'change', addImageInput
    
  $('select').material_select

  $('.dropdown-button').dropdown
    inDuration: 300
    outDuration: 225
    constrain_width: false
    hover: true
    gutter: 0
    belowOrigin: false

  return