$(document).on "ready page:change", ->
  projectMenuButton = document.getElementById("project-menu-button");
  if projectMenuButton
    projectMenuButton.addEventListener 'menuselect', (e) ->
      $.ajax url: $(e.detail.source).data('ajax-url'), method: $(e.detail.source).data('method')
      return

  $('#projects-overview').on 'toggle', (e) ->
    if e.detail.state == 'open'
      panel = $(e.detail.tabpanel)
      if !$.trim(panel.html())
        quarterButton = document.querySelector('#quarter-menu-button')
        selectedQuarter = quarterButton.MaterialExtMenuButton.getSelectedMenuItem()
        quarter = $(selectedQuarter).data('quarter')
        $.ajax "ministries/#{panel.data('stream')}/projects_overview/#{quarter}"
    return

  return

