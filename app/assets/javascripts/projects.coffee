$(document).on "ready page:change", ->

  $('#project-menu-button').on 'menuselect', (e) ->
    $.ajax url: $(e.detail.source).data('ajax-url'), method: $(e.detail.source).data('method'),
      headers: {Accept: "text/javascript"}
    return

  $('#quarter-menu-button').on 'menuselect', (e) ->
    selected = this.MaterialExtMenuButton.getSelectedMenuItem()
    accordion = document.querySelector('#projects-overview')
    accordion.MaterialExtAccordion.command({action: 'close'})
    $('#projects-overview-selected-quarter').html($(selected).html())
    $('.projects-overview-container').empty()
    return

  $('#projects-overview').on 'toggle', (e) ->
    if e.detail.state == 'open'
      panel = $(e.detail.tabpanel)
      if !$.trim(panel.html())
        quarterButton = document.querySelector('#quarter-menu-button')
        selectedQuarter = quarterButton.MaterialExtMenuButton.getSelectedMenuItem()
        quarter = $(selectedQuarter).data('quarter')
        $.ajax url: "ministries/#{panel.data('stream')}/projects_overview/#{quarter}", headers: {Accept: "text/javascript"}
    return

  return

