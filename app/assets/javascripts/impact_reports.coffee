# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

filter_impact_reports = ->

  # mark the cards that aren't in the selected geo_state
  state_id = $('#geo_state_id').val()
  $('.card.impact_report.for-tagging').addClass 'wrong-state'
  $('.card.impact_report.for-tagging[data-geo-state="' + state_id + '"]').removeClass 'wrong-state'

  # mark the cards that aren't in one of the selected languages.
  $('.card.impact_report.for-tagging').addClass 'wrong-language'
  $('#language-selected-dropdown input:checkbox:checked').each ->
    lang_id = $(this).attr('id').split('_').pop()
    $('.card.impact_report.for-tagging[data-language~="' + lang_id + '"]').removeClass 'wrong-language'
    return

  # Hide the marked cards
  $('.card.impact_report.for-tagging').removeClass 'hide'
  $('.card.impact_report.for-tagging.wrong-state').addClass 'hide'
  $('.card.impact_report.for-tagging.wrong-language').addClass 'hide'

  return

$(document).ready ->

  filter_impact_reports()

  $('.card.impact_report.for-tagging').leanModal

    ready: ->
      content = $('.card.impact_report.for-tagging.selected .report-content').text()
      $('#pm-modal .report-content').text content
      # check the progress markers that already belong to the selected report
      $('#pm-modal input:checkbox').prop 'checked', false
      jQuery.each $('.card.impact_report.for-tagging.selected').attr('data-pm').split(' '), (index, pm_id) ->
        $('#pm-modal input:checkbox#pm-' + pm_id).prop 'checked', true
        return
      return

    complete: ->
      # collapse the collapsible inside the modal
      $('#pm-modal .collapsible-header.active').trigger('click')

      # collect the selected PMs
      pms = []
      $('#pm-modal input:checkbox:checked').each ->
        pms.push $(this).attr('id').split('-').pop()
        return

      # update the actual report
      report_id = $('.card.impact_report.for-tagging.selected').attr('id').split('-').pop()
      jQuery.post report_id + '/tag_update', { _method: "patch", pm_ids: pms }, (data) ->
        # we receive back a collection of the reports new PMs
        new_pm_ids = []
        $('.card.impact_report.for-tagging.selected .progress_markers').empty()
        jQuery.each data, (index, pmData) ->
          pmObj = jQuery.parseJSON(pmData)
          new_pm_ids.push pmObj.id
          new_pm_element = $('<li/>',
              'text': pmObj.name
              'class': 'progress_marker tooltipped ' + pmObj.colour
              'data-postion': 'bottom'
              'data-delay': '50'
              'data-tooltip': pmObj.description
            )
          $('.card.impact_report.for-tagging.selected .progress_markers').append(new_pm_element)
          return
        $('.tooltipped').tooltip()
        $('.card.impact_report.for-tagging.selected').attr 'data-pm', new_pm_ids.join ' '

        # cards with no PMs are lighter coloured
        if new_pm_ids.length > 0
          $('.card.impact_report.for-tagging.selected').removeClass 'lighten-3'
          $('.card.impact_report.for-tagging.selected').addClass 'lighten-1'
        else
          $('.card.impact_report.for-tagging.selected').removeClass 'lighten-1'
          $('.card.impact_report.for-tagging.selected').addClass 'lighten-3'
        return

      return

  $('.progress-marker-input select').change ->
  	marker_id = $(this).val()
  	if marker_id.length > 0
  	  report_id = $(this).parents('.report-tagging').find('.report').attr('id').split('-').pop()
  	  $.post report_id + '/tag_update', { _method: "patch", pm_id: marker_id }, (data) ->
  	    if data.indexOf "success" >= 0
  	  	  $('#report-' + report_id).parents('.report-tagging').addClass('completed').fadeOut()
  	    return
  	return

  $('.card.impact_report.for-tagging').click ->
    $('.card.impact_report.for-tagging.selected').removeClass('z-depth-1 selected').addClass('z-depth-3')
    $(this).removeClass('z-depth-3').addClass('z-depth-1 selected')
    return

  $('#geo_state_id').on 'change', filter_impact_reports
  $('#language-selected-dropdown input').on 'change', filter_impact_reports
  
  return