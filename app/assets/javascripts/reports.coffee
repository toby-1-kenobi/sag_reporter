# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

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

  return