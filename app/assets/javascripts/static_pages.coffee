# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "ready page:change", ->

  $('.button-collapse').sideNav()

  $('#get-national-chart-link').click()

  $('#report-tasks-trigger').on 'click', ->
    console.log 'report tasks'
    $('#report-dialog')[0].showModal()
    return

  $('#report-dialog').find('.close').on 'click', ->
    $('#report-dialog')[0].close()
    return

  $('#progress-tasks-trigger').on 'click', ->
    console.log 'progress tasks'
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

  $('#reset-password-trigger').on 'click', ->
    $('#resetpassword-dialog')[0].showModal()
    return

  $('#resetpassword-dialog').find('.close').on 'click', ->
    $('#resetpassword-dialog')[0].close()
    return

  return