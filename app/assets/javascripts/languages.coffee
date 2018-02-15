# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

generateFilterParams = ->
  visible = {}
  $('.visible-flm-filter:checked').each ->
    flmID = $(this).val()
    visible[flmID] = []
    $("#flm-filter-#{flmID} input:checkbox:checked").each ->
      visible[flmID].push($(this).attr('data-status-id'))
  flms = Object.keys(visible)
  filterParams = "?filter=#{flms.join()}"
  filterParams = "#{filterParams}-#{visible[flm].join('')}" for flm in flms
  return filterParams


$(document).ready ->

  $('.get-chart-button').click()

  $('#jp-fetch-trigger').click()

  $('.editable').hover (->
    $(this).find('.edit-icon').removeClass('hide')
    return
  ), ->
    $(this).find('.edit-icon').addClass('hide')
    return

  $('.editable').on 'click', ->
    id = this.id
    if $(this).hasClass('finish-line-progress-status')
      number = id.substring(id.lastIndexOf('-') + 1)
      $("dialog#finish-line-dialog-#{number}").get(0).showModal()
    else
      $("dialog[data-for=\"#{id}\"]").get(0).showModal()
    return

  $('.language-table .flm-status-select select').on 'change', (event) ->
    $(this).closest('form').submit()

  $('.finish-line-progress-icon').on 'click', ->
    id = this.id
    number = id.substring(id.lastIndexOf('-') + 1)
    $("dialog#finish-line-dialog-#{number}").get(0).showModal()

  $('.add-engaged-org-button').on 'click', ->
    $('#add-engaged-org-dialog').get(0).showModal()
    return

  $('.add-translating-org-button').on 'click', ->
    $('#add-translating-org-dialog').get(0).showModal()
    return

  prev_adjust = ''

  $('.colour-darkness-range').on 'change', ->
  	value = $(this).val()
  	if value < 0 
  	  colour_adjust = 'lighten-' + (value * -1)
  	else
  	  if value > 0
  	    colour_adjust = 'darken-' + $(this).val()
  	  else
  	    colour_adjust = ''
  	if prev_adjust != ''
  	  $(this).parents('#colour_picker').find('td').removeClass(prev_adjust)
  	if colour_adjust != ''
  	  $(this).parents('#colour_picker').find('td').addClass(colour_adjust)
  	prev_adjust = colour_adjust
  	return

  $('.language-filter-controls .over').on 'click', ->
    # get the thing that will slide out from under
    under = $(this).nextAll('.under:first')
    if ($(under).is(":visible"))
      under.removeClass('mdl-shadow--4dp')
      under.children('.shadow-clipper').fadeOut 200, ->
        under.slideUp(300)
    else
      under.slideDown 300, ->
        under.addClass('mdl-shadow--4dp')
        under.children('.shadow-clipper').fadeIn(200)

  $('#finish-line-marker-select').on 'click', (event) ->
    event.stopPropagation()
    return

  $('.flm-option').on 'click', (event) ->
    event.stopPropagation()
    # hide any visible under panels
    $('.finish-line-filter-panel:visible')
      .removeClass('mdl-shadow--4dp')
      .children('.shadow-clipper').fadeOut 200, ->
        $('.finish-line-filter-panel:visible').slideUp(300)
        return
    # make all panels not 'under'
    $('.under.finish-line-filter-panel').addClass('hide').removeClass('under')
    # recheck every checkbox and refilter to remove finish line filter
    $('.finish-line-filter-panel').find('input:checkbox:not(:checked)').each ->
      console.log(this)
      $(this).parent()[0].MaterialCheckbox.check()
      $(this).trigger('change')
      return
    # set the name on the filter box to the selected finish line marker
    $('#flm-filter-name').html($(this).find('.flm-name').html())
    # hide all finish line chips in the language list
    $('.language-flp-chip').addClass('hide')
    # show the chips related to the selected marker
    flmNum = $(this).attr('data-flm-number')
    $(".language-flp-chip.flm-#{flmNum}").removeClass('hide')
    # make the proper filter options the ones that will come up when the filter is clicked
    $("#finish-line-status-select-#{flmNum}").addClass('under').removeClass('hide')
    return

  $('#visible-flms-dialog-trigger').on 'click', ->
    document.querySelector('#dialog-visible-flms').showModal()

  $('.visible-flm-filter').on 'change', ->
    filterParams = generateFilterParams()
    if history.state != filterParams
      history.pushState(filterParams, '', filterParams)

  $('#flm-filter-reset').on 'click', ->
    # gather one checkbox from each flm to trigger change for refilter
    changedBoxes = {}
    $('.language-table tr.filters .mdl-js-checkbox:not(.is-checked)').each ->
      this.MaterialCheckbox.check()
      changedBoxes[$(this).find('input').attr('data-filter-trigger-label')] = this
    for flm, checkbox of changedBoxes
      $(checkbox).find('input').trigger 'change'

  $('.filter-summary').on 'click', ->
    $(this).parent().find('.filter-choices').slideToggle()

  $('.filter-choices input').on 'change', ->
    flmNum = $(this).attr('data-filter-trigger-label')
    unchecked = $(this).closest('.filter-choices').find('input[type="checkbox"]:not(:checked)')
    checked = $(this).closest('.filter-choices').find('input:checked[type="checkbox"]')
    if unchecked.length == 0
      $("##{flmNum}-filter-summary").text('Showing All')
    else if checked.length == 0
      $("##{flmNum}-filter-summary").text('Showing None')
    else
      $("##{flmNum}-filter-summary").text('Filtered')
    filterParams = generateFilterParams()
    if history.state != filterParams
      history.pushState(filterParams, '', filterParams)

  $('.language-row select').on 'change', ->
    newValue = $(this).val()
    newCategory = $('.language-table').attr("data-flm-category__#{newValue}")
    flmNumber = $(this).attr('flm_number')
    $(this).closest('.mdl-js-selectfield').attr('data-finish-line-category', newCategory)
    $(this).closest('.language-row').attr("data-flm-#{flmNumber}", newValue)
    # force refiltering in case row should now be hidden
    $("#flm-#{flmNumber}-filter-#{newValue}").trigger('change')

  $('#champion-edit-button').on 'click', ->
    $('#champion-input-row').slideDown()
    return

  $('#champion-input').on 'railsAutocomplete.select', (event, data) ->
    $('#set-champion-form').submit()
    $('#champion-input-row').slideUp()
    return

  return