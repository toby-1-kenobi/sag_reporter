registerDialogs = ->
  $('dialog.mdl-dialog:not(.registered)').each ->
    dialog = this
    if !dialog.showModal
      dialogPolyfill.registerDialog dialog
    $(dialog).find('.submit').on 'click', ->
      $(dialog).find('form').submit()
      dialog.close()
      return
    $(dialog).find('.cancel,.close').on 'click', ->
      dialog.close()
      return
    $(dialog).addClass 'registered'
    return
  return

