# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

rowCount = 0

addRow = ->
  rowCount += 1
  newRow = $('<tr class="repeatable"></tr>')
  newRow.html($(this).parents('.repeatable').html().replace(/__\d+/g, '__' + rowCount))
  selectParent = newRow.find('.select-wrapper').parent()
  realSelect = newRow.find('select')
  selectParent.html(realSelect)
  $(this).off 'change', addRow
  realSelect.on 'change', addRow
  newRow.hide()
  $(this).parents('.repeatable').after newRow
  realSelect.material_select()
  newRow.delay(200).fadeIn 'slow'
  return

$(document).ready ->
  $('.repeatable select').on 'change', addRow
  return