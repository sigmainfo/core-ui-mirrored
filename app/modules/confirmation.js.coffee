#= require environment
#= require jquery.ui.position
#= require templates/modules/confirmation

KEYCODE =
  esc: 27
  enter: 13

Coreon.Modules.Confirmation =

  confirm: (options = {}) ->
    template = options.template or Coreon.Templates['modules/confirmation']
    message = options.message
    trigger = $ options.trigger
    action =
      if _(options.action).isString()
        @[options.action]
      else
        options.action
    container = $ options.container

    shim = $(template message: message)
    dialog = shim.find('.dialog')

    shim.appendTo('#coreon-modal')
    container.addClass 'delete'

    position = ->
      dialog
        .position
          my: 'left bottom'
          at: 'left-34 top-12'
          of: trigger
          collision: 'flip'
        .toggleClass('y-flipped'
                   , dialog.offset().top > trigger.offset().top)
        .toggleClass('x-flipped'
                   , trigger.offset().left - dialog.offset().left > 50)

    position()
    $(window).on 'scroll.coreonConfirmation resize.coreonConfirmation', position

    destroy = ->
      $(window).off '.coreonConfirmation'
      container.removeClass 'delete'
      shim.remove()

    shim.on 'click.coreonConfirmation', 'a.cancel', destroy

    confirm = =>
      destroy()
      action.call @

    shim.on 'click.coreonConfirmation', 'a.confirm', confirm

    $(window).on 'keydown.coreonConfirmation', (event) ->
      switch event.keyCode
        when KEYCODE.esc   then destroy()
        when KEYCODE.enter then confirm()
