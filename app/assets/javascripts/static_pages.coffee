# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

  $('.button-collapse').sideNav()

  $('#get-national-chart-link').click()

  $('.home-link').on 'mouseover', ->
    $(this).removeClass('z-depth-2').addClass('z-depth-3 lighten-2')
    return

  $('.home-link').on 'mouseout', ->
    $(this).removeClass('z-depth-3 lighten-2').addClass('z-depth-2')
    return

  $('.home-link').on 'click', ->
    $(this).removeClass('z-depth-3')
    return

  $('#report-tasks-trigger').on 'click', ->
    $('#report-dialog')[0].showModal()
    return

  $('#report-dialog').find('.close').on 'click', ->
    $('#report-dialog')[0].close()
    return

  $('#progress-tasks-trigger').on 'click', ->
    $('#progress-dialog')[0].showModal()
    return

  $('#progress-dialog').find('.close').on 'click', ->
    $('#progress-dialog')[0].close()
    return

  $('#admin-tasks-trigger').on 'click', ->
    $('#other-dialog')[0].showModal()
    return

  $('#other-dialog').find('.close').on 'click', ->
    $('#other-dialog')[0].close()
    return

  return