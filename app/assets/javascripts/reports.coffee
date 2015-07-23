# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('#show_archived_reports').change ->
    if @checked
      $('.report.archived').removeClass 'hide'
    else
      $('.report.archived').addClass 'hide'
    return
  return