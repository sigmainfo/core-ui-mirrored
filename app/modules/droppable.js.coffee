#= require environment
#= require jquery.ui.droppable

# make drop zones
# Options can be overwritten via attribute and are the same as for
# JQueryUI.droppable.
#
# Parameters:
# 
#   el: dropzone element
#   dragElClass: class to add to valid hovering draggables
#   options: options hash to overwrite defaults for jqueryui.droppable
#
# Example:
#
# class Coreon.View.Something extends Backbone.View
#   Coreon.Modules.include @, Coreon.Modules.Droppable
#   initialize: ->
#     droppableOn ".selector", "dragElClass",
#       accept: (el)-> ...


Coreon.Modules.Droppable =

  _droppable_onEnter: (evt, ui) ->
    el = ui.helper
    cssClass = @options.dragElClass

    @disableForeigners() if @options.disableForeigners
    if @options.fake
      $.ui.ddmanager.current.element.draggable "option", "revert", true
    else
      $.ui.ddmanager.current.element.draggable "option", "revert", "invalid"
      $(el).addClass cssClass

  _droppable_onLeave: (evt, ui) ->
    el = ui.helper
    cssClass = @options.dragElClass

    @enableForeigners() if @options.disableForeigners
    if @options.fake
      $.ui.ddmanager.current.element.draggable "option", "revert", "invalid"
    else
      $.ui.ddmanager.current.element.draggable "option", "revert", true
    $(el).removeClass cssClass

  _droppable_onDrop: (evt, ui) ->
    _.defer =>
      @enableForeigners() if @options.disableForeigners

  disableForeigners: ->
    @_disabledForeigners = []
    for el in $('.ui-droppable', '#coreon-main')
      $el = $(el)
      if $el.data("uiDroppable") and $el.droppable("option", "disabled") == false
        @_disabledForeigners.push $el
        dragElClass = $el.droppable "option", "dragElClass"
        $.ui.ddmanager.current.helper.removeClass dragElClass
        $el.droppable("option", "disabled", true)

  enableForeigners: ->
    for $el in @_disabledForeigners
      $el.droppable("option", "disabled", false)
      if $el.hasClass "ui-state-hovered"
        $.ui.ddmanager.current.helper.addClass $el.droppable("option", "dragElClass")

  droppableOn: (el, dragElClass="ui-droppable-hovered", options={})->
    _dropzone = $(el)

    defaults =
      greedy: true
      activeClass: "ui-state-highlight"
      hoverClass: "ui-state-hovered"
      tolerance: "pointer"
      over: (evt, ui) => @_droppable_onEnter(evt, ui)
      out: (evt, ui) => @_droppable_onLeave(evt, ui)
      dragElClass: dragElClass
      disableForeigners: false
      fake: false
      drop: (evt, ui) => @_droppable_onDrop(evt, ui)

    @options = _.extend defaults, options
    _dropzone.droppable @options
    _dropzone.droppable "enable"

  droppableOff: (el)->
    _dropzone = $(el)
    _dropzone.droppable "disable"

