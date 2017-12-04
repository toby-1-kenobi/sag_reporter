$(document).ready ->

  $('#add-pop-fab').on 'click', ->
    console.log 'hi'
    $('dialog#edit-dialog-population').get(0).showModal()
    return

  return