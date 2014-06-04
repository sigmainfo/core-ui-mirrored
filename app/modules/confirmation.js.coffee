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
    container = $ options.container if options.container?
    action =
      if _(options.action).isString()
        @[options.action]
      else
        options.action

    container?.addClass "delete"
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
      container?.removeClass "delete"
      modal.empty()

    confirm = (event) =>
      event.stopPropagation()
      $(window).off ".coreonConfirm"
      modal.empty()
      action.call @

    position()
    $(window).on "scroll.coreonConfirm resize.coreonConfirm", position

    $(window).on "keydown.coreonConfirm", (event) ->
      switch event.keyCode
        when KEYCODE.esc   then cancel event
        when KEYCODE.enter then confirm event

    shim.click cancel
    dialog.click confirm
