# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

#  $('select').material_select

  $('.dropdown-button').dropdown
    inDuration: 300
    outDuration: 225
    constrain_width: false
    hover: true
    gutter: 0
    belowOrigin: false

  return