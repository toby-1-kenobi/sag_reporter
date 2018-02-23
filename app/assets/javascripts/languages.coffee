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
  filterParams = flms.join('_')
  filterParams = "#{filterParams}-#{visible[flm].join('')}" for flm in flms
  return filterParams

getActiveTab = ->
  if $('.mdl-tabs__panel.is-active').length > 0
    $('.mdl-tabs__panel.is-active').first().attr('id').split('-')[0]
  else
    ''

setActiveTab = (tabName) ->
  $('.dashboard-tabs .mdl-tabs__tab').removeClass('is-active')
  $(".dashboard-tabs .mdl-tabs__tab[href=\"##{tabName}-tab\"").addClass('is-active')
  $('.dashboard-tabs .mdl-tabs__panel').removeClass('is-active')
  $("##{tabName}-tab").addClass('is-active')

applyFilterParams = (filterParams) ->
  tokens = filterParams.split('-')
  visibleFLMs = tokens.shift().split(',')
  $('#dialog-visible-flms .mdl-switch').each ->
    if visibleFLMs.includes $(this).attr('id').split('-')[1]
      $(this)[0].MaterialSwitch.on()
    else
      $(this)[0].MaterialSwitch.off()
  $('#dialog-visible-flms .mdl-switch input').first().trigger('change')
  for flmNumber in visibleFLMs
    if tokens.length > 0
      filters = tokens.shift().split('')
    else
      filters = []
    console.log filters
    $("#flm-filter-#{flmNumber} .mdl-checkbox").each ->
      if filters.includes $(this).find('input').attr('data-status-id')
        $(this)[0].MaterialCheckbox.check()
      else
        $(this)[0].MaterialCheckbox.uncheck()
    $("#flm-filter-#{flmNumber} .mdl-checkbox input").first().trigger('change')

updateState = ->
  filterParam = generateFilterParams()
  tabParam = getActiveTab()
  newState = { filter: filterParam, tab: tabParam }
  if history.state != newState
    history.pushState(newState, '', "?filter=#{filterParam}&tab=#{tabParam}")


window.onpopstate = (event) ->
  if event.state != null
    if event.state.tab != null
      setActiveTab(event.state.tab)
    if event.state.filter != null
      applyFilterParams(event.state.filter)

$(document).ready ->

  $('.get-chart-button').click()

  $('#jp-fetch-trigger').click()

  $('.dashboard-tabs a').on 'click', ->
    if history.state != null
      filterParam = history.state.filter
    else
      filterParam = generateFilterParams()
    tabParam = $(this).attr('href').split('-')[0].substr(1)
    newState = { filter: filterParam, tab: tabParam }
    if history.state != newState
      history.pushState(newState, '', "?filter=#{filterParam}&tab=#{tabParam}")

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


  $('#visible-flms-dialog-trigger').on 'click', ->
    document.querySelector('#dialog-visible-flms').showModal()

  $('#dialog-visible-flms').on 'close', ->
    updateState()

  $('#flm-filter-reset').on 'click', ->
    # gather one checkbox from each flm to trigger change for refilter
    changedBoxes = {}
    $('.language-table tr.filters .mdl-js-checkbox:not(.is-checked)').each ->
      this.MaterialCheckbox.check()
      changedBoxes[$(this).find('input').attr('data-filter-trigger-label')] = this
    for flm, checkbox of changedBoxes
      $(checkbox).find('input').trigger 'change'
    updateState()

  $('.filter-summary').on 'click', ->
    $(this).parent().find('.filter-choices').slideToggle()
    updateState()

  $('.filter-choice-done').on 'click', ->
    $(this).closest('.filter-choices').slideUp()
    updateState()

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