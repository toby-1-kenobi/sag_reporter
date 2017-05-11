$(document).ready ->
  $('.pie-toggle').on 'click', ->
    $(this).siblings('i').toggle()
    $("##{$(this).attr('data-chart')}").toggle()
    return

