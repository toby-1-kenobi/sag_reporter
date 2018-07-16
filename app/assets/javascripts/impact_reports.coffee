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

$(document).on "ready page:change", ->

  $('.report .tag-button').on 'click', ->
    $('#tag-dialog')[0].showModal();
    return

  filter_impact_reports()

  $('.card.impact_report.for-tagging.shareable .card-content').append('<div class="chip share">Can be shared with funders</div>')

  $('.card.impact_report.for-tagging .card-content').leanModal

    ready: ->
      content = $('.card.impact_report.for-tagging.selected .report-content').text()
      $('#pm-modal .report-content').text content
      # check the progress markers that already belong to the selected report
      $('#pm-modal input:checkbox').prop 'checked', false
      jQuery.each $('.card.impact_report.for-tagging.selected').attr('data-pm').split(' '), (index, pm_id) ->
        $('#pm-modal input:checkbox#pm-' + pm_id).prop 'checked', true
        return
      # reset the pictures
      reportID = $('.card.impact_report.for-tagging.selected').attr('data-report-id')
      $('#pm-modal .pictures').addClass('hide').empty().attr('data-report-id', reportID)
      if parseInt($('.card.impact_report.for-tagging.selected').attr('data-pictures')) > 0
        $('#pm-modal .get-pictures-trigger').attr('data-report-id', reportID).removeClass('hide')
        href = $('#pm-modal .get-pictures-trigger a').attr('href').replace(/\/\d+\//, '/' + reportID + '/')
        $('#pm-modal .get-pictures-trigger a').attr('href', href)
      else
        $('#pm-modal .get-pictures-trigger').
          attr('data-report-id', 'x').
          addClass('hide')
      # set the shareable checkbox
      if $('.card.impact_report.for-tagging.selected.shareable').length > 0
        $('input:checkbox#shareable').prop 'checked', true
      else
        $('input:checkbox#shareable').prop 'checked', false
      return


    complete: ->
      # collapse the collapsible inside the modal
      $('#pm-modal .collapsible-header.active').trigger('click')

      # find the card and report id
      report_card = $('.card.impact_report.for-tagging.selected')
      report_id = report_card.attr('id').split('-').pop()

      # if it's not an impact report send ajax to change it
      # and remove it from the DOM
      if($('#pm-modal .not-impact-checkbox input:checkbox').is(':checked'))
        not_impact_url = '/impact_reports/' + report_id + '/not_impact'
        report_card.remove()
        jQuery.post not_impact_url, { _method: "patch" }

      else
        # collect the selected PMs
        pms = []
        $('#pm-modal .pm-checkbox input:checkbox:checked').each ->
          pms.push $(this).attr('id').split('-').pop()
          return

        # update the actual report
        ajax_url = $('#ajax-path').text().replace('report_id', report_id)
        jQuery.post ajax_url, { _method: "patch", pm_ids: pms }, (data) ->
          # we receive back a collection of the reports new PMs
          new_pm_ids = []
          $('.card.impact_report.for-tagging.selected .progress_markers').empty()
          jQuery.each data, (index, pmData) ->
            pmObj = jQuery.parseJSON(pmData)
            new_pm_ids.push pmObj.id
            new_pm_element = $('<li/>',
                'text': pmObj.description
                'class': 'progress_marker tooltipped ' + pmObj.colour
                'data-postion': 'bottom'
                'data-delay': '50'
                'data-tooltip': pmObj.number
              )
            $('.card.impact_report.for-tagging.selected .progress_markers').append(new_pm_element)
            return
          $('.tooltipped').tooltip()
          report_card.attr 'data-pm', new_pm_ids.join ' '

          # cards with no PMs are lighter coloured
          if new_pm_ids.length > 0
            report_card.removeClass 'lighten-3'
            report_card.addClass 'lighten-1'
          else
            report_card.removeClass 'lighten-1'
            report_card.addClass 'lighten-3'
          return

        # if the shareable checkbox is toggled change the attribute with ajax
        if $('.card.impact_report.for-tagging.selected.shareable').length > 0
          if $('input:checkbox#shareable').is(':not(:checked)')
            not_shareable_url = '/impact_reports/' + report_id + '/not_shareable'
            $('.card.impact_report.for-tagging.selected').removeClass('shareable')
            $('.card.impact_report.for-tagging.selected .chip.share').remove()
            jQuery.post not_shareable_url, { _method: "patch" }

        if $('.card.impact_report.for-tagging.selected.shareable').length == 0
          if $('input:checkbox#shareable').is(':checked')
            shareable_url = '/impact_reports/' + report_id + '/shareable'
            $('.card.impact_report.for-tagging.selected').addClass('shareable')
            $('.card.impact_report.for-tagging.selected .card-content').append('<div class="chip share">Can be shared with funders</div>')
            jQuery.post shareable_url, { _method: "patch" }

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

  $('.card.impact_report.for-tagging .card-content').click ->
    $('.card.impact_report.for-tagging.selected').removeClass('z-depth-1 selected').addClass('z-depth-3')
    $(this).parent('.card').removeClass('z-depth-3').addClass('z-depth-1 selected')
    return

  $('#geo_state_id').on 'change', filter_impact_reports
  $('#language-selected-dropdown input').on 'change', filter_impact_reports

  $('.date-filter').on 'change', ->
    from = new Date(Date.parse($('#from_date').val()))
    to = new Date(Date.parse($('#to_date').val()))
    $('.filterable-item[data-date]').addClass('filter-out-date')
    $('.filterable-item[data-date]').each ->
      date = new Date(Date.parse($(this).attr('data-date')))
      if date >= from and date <= to
        $(this).removeClass 'filter-out-date'
      return
    $('.filterable-item[data-date]').addClass('hide')
    $('.filterable-item[data-date]').not('[class*="filter-out"]').removeClass('hide')
    return
  
  return