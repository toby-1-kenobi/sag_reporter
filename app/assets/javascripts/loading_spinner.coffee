
$(document).on 'page:fetch', ->
  $('div#page-spinner').addClass('is-active')

$(document).on 'ready page:change', ->
  $('div#page-spinner').removeClass('is-active')