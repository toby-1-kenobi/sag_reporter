
# when a state is selected the language collections on the page
# should hide any that don't belong to the state.
# filterable items in those collection have the class filterable-item
# and a data attribute with a comma-seperate list of identifiers
# that match potential filter values.

checkRefilter = (refilter, element) ->
  if element.hasClass 'filter-trigger'
    label = element.attr 'data-filter-trigger-label'
    if !label
      label = "<global>"
    refilter[label] = element
  return

applyFilter = (filterValues, filterLabel) ->
  console.log "filter: #{filterLabel} #{filterValues}"
  if filterLabel
    filterableItems = $('.filterable-item[data-filter-label*=' + filterLabel + ']')
    filterOut = 'filter-out-' + filterLabel
  else
    filterableItems = $('.filterable-item')
    filterOut = 'filter-out'
  filterableItems.each ->
    thisItem = $(this)
    data1 = thisItem.attr('data')
    data2 = thisItem.attr('data-' + filterLabel)
    if data1 and data2
      data = jQuery.merge data1.split(','), data2.split(',')
    else if data1
      data = data1.split(',')
    else if data2
      data = data2.split(',')
    else
      return
    thisItem.addClass filterOut
    jQuery.each data, (index, value) ->
      if jQuery.inArray(value, filterValues) >= 0
        thisItem.removeClass filterOut
      return
    return

  filterableItems.addClass 'hide'
  filterableItems.not('[class*="filter-out"]').removeClass 'hide'

  # We're going to uncheck and check some checkboxes
  # so we need to refilter after that
  # store the checkbox to refilter by here
  # use association because we only need to do it once for each label
  refilter = {}

  # if we've hidden any checked checkboxes they should be unchecked
  $('input:checkbox:checked.filterable-item.hide').each ->
    $(this).prop 'checked', false
    $(this).addClass 'was-checked'
    checkRefilter refilter, $(this)
    return
  $('.filterable-item.hide:not(.filter-inverse) input:checkbox:checked').each ->
    $(this).prop 'checked', false
    $(this).addClass 'was-checked'
    checkRefilter refilter, $(this)
    return
  # in some cases hidden checkbozxes should be checked
  $('.filterable-item.hide.filter-inverse input:checkbox:not(:checked)').each ->
    $(this).prop 'checked', true
    $(this).addClass 'was-unchecked'
    checkRefilter refilter, $(this)
    return

  # checkboxes that have become visible and used to be checked,
  # should be checked again.
  $('input:checkbox.was-checked.filterable-item:not(.hide)').each ->
    $(this).prop 'checked', true
    $(this).removeClass 'was-checked'
    checkRefilter refilter, $(this)
    return
  $('.filterable-item:not(.hide) input:checkbox.was-checked').each ->
    $(this).prop 'checked', true
    $(this).removeClass 'was-checked'
    checkRefilter refilter, $(this)
    return
  # and the ones that used to be unchecked should be checked again
  $('.filterable-item:not(.hide) input:checkbox.was-unchecked').each ->
    $(this).prop 'checked', false
    $(this).removeClass 'was-unchecked'
    checkRefilter refilter, $(this)
    return

  for label of refilter
    # use hasOwnProperty to filter out keys from the Object.prototype
    if refilter.hasOwnProperty(label)
      refilter[label].trigger 'change'

  return

filterOnLabel = (label) ->
  if label
    allTriggers = $('.filter-trigger[data-filter-trigger-label="' + label + '"]').not('input:checkbox:not(:checked)').not('input:radio:not(:checked)')
  else
    allTriggers = $('.filter-trigger').not('input:checkbox:not(:checked)').not('input:radio:not(:checked)')
  valueArray = allTriggers.map ->
    return $(this).val()
  applyFilter valueArray, label
  return

window.bindFilters = ->
  $('.filter-trigger').on 'change', ->
    filterOnLabel($(this).attr 'data-filter-trigger-label')
    return


$(document).on "ready page:change", ->

  window.bindFilters()


  $('.filter-trigger').trigger 'change'

  return