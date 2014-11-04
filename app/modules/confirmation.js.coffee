#= require environment
#= require jquery.ui.position
#= require templates/concepts/_confirm

KEYCODE =
  esc: 27
  enter: 13

template = Coreon.Templates["concepts/confirm"]

Coreon.Modules.Confirmation =

  confirm: (options = {}) ->
    trigger = $ options.trigger
    modal = $ "#coreon-modal"
    shim = $ template message: options.message
    dialog = shim.find ".confirm"

    options.container?.addClass "delete"
    shim.appendTo modal

    position = ->
      dialog
        .position
          my: "left bottom"
          at: "left-34px top-12"
          of: trigger
          collision: "none flip"
        .toggleClass "flipped",
          dialog.offset().top > trigger.offset().top

    cancel = ->
      $(window).off ".coreonConfirm"
      options.container?.removeClass "delete"
      modal.empty()
      options.restore()

    destroy = (event) ->
      event.stopPropagation()
      $(window).off ".coreonConfirm"
      modal.empty()
      options.action()

    position()
    $(window).on "scroll.coreonConfirm resize.coreonConfirm", position

    $(window).on "keydown.coreonConfirm", (event) ->
      switch event.keyCode
        when KEYCODE.esc   then cancel event
        when KEYCODE.enter then destroy event

    shim.click cancel
    dialog.click destroy
