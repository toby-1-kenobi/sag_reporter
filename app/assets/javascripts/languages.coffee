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
    $("#flm-filter-#{flmNumber} .mdl-checkbox").each ->
      if filters.includes $(this).find('input').attr('data-status-id')
        $(this)[0].MaterialCheckbox.check()
      else
        $(this)[0].MaterialCheckbox.uncheck()
    $("#flm-filter-#{flmNumber} .mdl-checkbox input").first().trigger('change')
  $('#language_csv').attr("href", "/language_tab_spreadsheet.csv?flm_filters=#{filterParams}")

window.updateState = ->
  filterParam = generateFilterParams()
  $('#language_csv').attr("href", "/language_tab_spreadsheet.csv?flm_filters=#{filterParam}")
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

$(document).on "page:change", ->

  $('.get-chart-button').click()

  $('#jp-fetch-trigger').click()

  $('.content-fetch-trigger').on 'click', ->
    $(this).parent().find('.mdl-spinner').addClass('is-active')
    $(this).hide()

  $('.mdl-tabs__panel.is-active .content-fetch-trigger').click()


  $('.dashboard-tabs .mdl-tabs__tab-bar a').on 'click', ->
    if history.state != null
      filterParam = history.state.filter
    else
      filterParam = generateFilterParams()
    tabID = $(this).attr('href').substr(1)
    tabParam = tabID.split('-')[0]
    $("##{tabID} .content-fetch-trigger").click()
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

  $('#champion-edit-button').on 'click', ->
    $('#champion-input-row').slideDown()
    return

  $('#champion-input').on 'railsAutocomplete.select', (event, data) ->
    $('#set-champion-form').submit()
    $('#champion-input-row').slideUp()
    return

  $('#project-edit-button').on 'click', ->
    $('#project-input-row').slideDown()
    return

  $('#language-project-select').on 'change', ->
    $(this).closest('form').submit()
    $('#project-input-row').slideUp()

  return