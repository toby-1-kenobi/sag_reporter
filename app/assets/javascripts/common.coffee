
# when a state is selected the language collections on the page
# should hide any that don't belong to the state.
# filterable items in those collection have the class filterable_item
# and a data attribute with a comma-seperate list of identifiers
# that match potential filter values.

applyFilter = (filterValues, filterLabel) ->
  console.log(filterLabel)
  if filterLabel
    filterableItems = $('.filterable_item[filter-label=' + filterLabel + ']')
  else
    filterableItems = $('.filterable_item')
  filterableItems.each ->
    thisItem = $(this)
    thisItem.addClass 'hide'
    jQuery.each thisItem.attr('data').split(','), (index, value) ->
      if jQuery.inArray(value, filterValues) >= 0
        thisItem.removeClass 'hide'
      return
    return
  # if we've hidden any checked checkboxes they should be unchecked
  $('input:checkbox:checked.filterable_item.hide').each ->
    $(this).prop 'checked', false
    if $(this).hasClass('filter-trigger') || $(this).hasClass('filter_trigger')
      $(this).trigger 'change'
    return
  $('.filterable_item.hide input:checkbox:checked').each ->
    $(this).prop 'checked', false
    if $(this).hasClass('filter-trigger') || $(this).hasClass('filter_trigger')
      $(this).trigger 'change'
    return
  return

$(document).ready ->

  $('.filter_trigger,.filter-trigger').on 'change', ->
    label = $(this).attr 'filter-trigger-label'
    allTriggers = $('.filter_trigger[filter-trigger-label="' + label + '"],.filter-trigger[filter-trigger-label="' + label + '"]').not('input:checkbox:not(:checked)')
    valueArray = allTriggers.map ->
      return $(this).val()
    applyFilter valueArray, label
    return

  return