
# when a state is selected the language collections on the page
# should hide any that don't belong to the state.
# filterable items in those collection have the class filterable-item
# and a data attribute with a comma-seperate list of identifiers
# that match potential filter values.

applyFilter = (filterValues, filterLabel) ->
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

  # if we've hidden any checked checkboxes they should be unchecked
  $('input:checkbox:checked.filterable-item.hide').each ->
    $(this).prop 'checked', false
    if $(this).hasClass('filter-trigger')
      $(this).trigger 'change'
    return
  $('.filterable-item.hide input:checkbox:checked').each ->
    $(this).prop 'checked', false
    if $(this).hasClass('filter-trigger')
      $(this).trigger 'change'
    return
  return

$(document).ready ->

  $('.filter-trigger').on 'change', ->
    label = $(this).attr 'data-filter-trigger-label'
    if label
      allTriggers = $('.filter-trigger[data-filter-trigger-label="' + label + '"]').not('input:checkbox:not(:checked)')
    else
      allTriggers = $('.filter-trigger').not('input:checkbox:not(:checked)')
    valueArray = allTriggers.map ->
      return $(this).val()
    applyFilter valueArray, label
    return

  return