$(document).on "ready page:change", ->

  $(document.body).on 'click', '.mdl-accordion__button', ->
    $(this).parent('.mdl-accordion').toggleClass('mdl-accordion--opened')

$(window).load ->

  # hide the accordian content by making the top margin negative the height
  $('.mdl-accordion__content').each ->
    content = $(this)
    content.css('margin-top', content.height() * -1)

