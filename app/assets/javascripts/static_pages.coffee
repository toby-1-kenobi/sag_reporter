# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:change", ->

  $(".button-collapse").sideNav()

  $('.home-link').on 'mouseover', ->
    $(this).removeClass('z-depth-2').addClass('z-depth-3 lighten-2')
    return

  $('.home-link').on 'mouseout', ->
    $(this).removeClass('z-depth-3 lighten-2').addClass('z-depth-2')
    return

  $('.home-link').on 'click', ->
    $(this).removeClass('z-depth-3')
    return

  return