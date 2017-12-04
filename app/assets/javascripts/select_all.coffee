$(document).ready ->

  # This code assumes we're using MDL for the checkboxes

  $('.select-all-trigger').on 'change', ->
    category = $(this).attr 'data-select-all-trigger'
    console.log(category)
    if $(this).is(':checked')
      $(".select-all-target:not(checked)[data-select-all-target=#{category}]").each ->
        $(this).parent()[0].MaterialCheckbox.check()
        $(this).trigger('change')
        return
    else
      $(".select-all-target:checked[data-select-all-target=#{category}]").each ->
        $(this).parent()[0].MaterialCheckbox.uncheck()
        $(this).trigger('change')
        return

  return