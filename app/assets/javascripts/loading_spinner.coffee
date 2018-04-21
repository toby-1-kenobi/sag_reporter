
$(document).on 'page:fetch', ->
  $('div#page-spinner').addClass('is-active')

$(document).on 'page:change', ->
  $('div#page-spinner').removeClass('is-active')