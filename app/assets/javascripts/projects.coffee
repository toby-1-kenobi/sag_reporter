$(document).on "ready page:change", ->
  projectMenuButton = document.getElementById("project-menu-button");
  if projectMenuButton
    projectMenuButton.addEventListener 'menuselect', (e) ->
      $.ajax url: $(e.detail.source).data('ajax-url'), method: $(e.detail.source).data('method')
      return


