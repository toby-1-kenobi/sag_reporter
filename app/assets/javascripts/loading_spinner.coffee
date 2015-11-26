@PageSpinner =
  spin: (ms=500)->
    @spinner = setTimeout( (=> @add_spinner()), ms)
    $(document).on 'page:change', =>
      @remove_spinner()
  add_spinner: ->
    $('div#page-spinner').openModal()
  remove_spinner: ->
    clearTimeout(@spinner)
    $('div#page-spinner').closeModal()

$(document).on 'page:fetch', ->
  PageSpinner.spin()