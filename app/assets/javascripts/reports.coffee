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
      if size_in_megabytes > 10
        alert 'This is a very large file and will take a long time to upload over a slow connection.'
    filename = $(this).val().split('\\').pop()
    if filename.length > 0
      list += '<li class="collection-item">' +
        '<label for="' + $(this).attr('id') + '" class="black-text">' +
        $(this).val().split('\\').pop() +
        '</label></li>'
    return
  $('#file-list').html(list)

updateDistrictData = ->
  geo_state_id = $('#report_geo_state_id').val()
  old_url = $('#district-autocomplete input').attr('data-autocomplete') 
  url = old_url.replace(/\d+/, geo_state_id)
  if old_url != url
    $('#sub-district-autocomplete').hide()
    $('#sub_district_name').val('')
    $('#location-input').hide()
    $('#district-autocomplete input').attr('data-autocomplete', url)
    $('#district-autocomplete input').val('')
  return

$(document).ready ->

  $('#report_geo_state_id').on 'change', updateDistrictData
  $('#district-autocomplete input').on 'railsAutocomplete.select', (event, data) ->
    old_url = $('#sub-district-autocomplete input').attr('data-autocomplete')
    url = old_url.replace(/\d+/, data.item.id)
    if old_url != url
      $('#location-input').hide()
      $('#sub_district_name').attr('data-autocomplete', url)
      $('#sub_district_name').val('')
      $('#sub-district-autocomplete').slideDown 400, ->
        $('#sub_district_name').focus()
        return
    return 
  $('#sub_district_name').on 'railsAutocomplete.select', (event, data) ->
    $('#location-input').slideDown 400, ->
      $('#location-input input').focus()
      return
    $('#report_sub_district_id').val(data.item.id)
    return

  $('#add-source-person').on 'click', ->
    fields = $('#observers_fields_template').clone()
    new_id = new Date().getTime();
    regexp = new RegExp('00000', 'g')
    $('#add-source-person').before(fields.html().replace(regexp, new_id))
    return

  $('#edit-location-button').on 'click', ->
    $('#show-location-data').addClass 'hide'
    $('#edit-location-data').removeClass 'hide'
    return

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
    
#  $('select').material_select

  $('.dropdown-button').dropdown
    inDuration: 300
    outDuration: 225
    constrain_width: false
    hover: true
    gutter: 0
    belowOrigin: false

  return