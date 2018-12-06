$(document).on "ready page:change", ->
  document.querySelector('#project-menu-button').addEventListener 'menuselect', (e) ->
    $.ajax url: $(e.detail.source).data('ajax-url'), method: $(e.detail.source).data('method')
    return


