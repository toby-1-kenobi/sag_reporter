
# when a state is selected the language collections on the page
# should hide any that don't belong to the state.
# filterable items in those collection have the class filterable_item
# and a data attribute with a comma-seperate list of identifiers
# that match potential filter values.

applyFilter = (filterValue) ->
  if filterValue
    $('.filterable_item').each ->
      thisItem = $(this)
      thisItem.addClass 'hide'
      jQuery.each thisItem.attr('data').split(','), (index, value) ->
        if filterValue == value
          thisItem.removeClass 'hide'
        return
      return
      # if we've hidden any checked checkboxes they should be unchecked
    $('input:checkbox:checked.filterable_item.hide').each ->
      $(this).prop 'checked', false
      return
    $('.filterable_item.hide input:checkbox:checked').each ->
      $(this).prop 'checked', false
      return
  return

$(document).ready ->
  applyFilter $('.filter_trigger').val()
  $('.filter_trigger').change ->
    applyFilter $(this).val()
    return
  return