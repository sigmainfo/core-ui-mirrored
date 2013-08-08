#= require environment
#= require jquery.ui.draggable

# make view element draggable
# Options can be overwritten via attribute and are the same as for
# JQueryUI.draggable.
#
# Parameters:
# 
#   el: element to drag
#   options: options hash to overwrite defaults for jqueryui.draggable
#
# Example:
#
# class Coreon.View.Something extends Backbone.View
#   Coreon.Modules.include @, Coreon.Modules.Draggable
#   initialize: ->
#     draggableOn ".selector"


Coreon.Modules.Draggable =

  _draggable_startDragging: (evt)->
    $(evt.target).addClass "ui-draggable-dragged"

  _draggable_stopDragging: (evt)->
    $(evt.target).removeClass "ui-draggable-dragged"

  draggableOn: (el, options={})->
    _draggableElement = $(el)

    # events
    _draggableElement.on "dragstart", @_draggable_startDragging
    _draggableElement.on "dragstop", @_draggable_stopDragging

    # jquery.ui.draggable magic
    _draggableElement.draggable
      revert:   (options.revert || "invalid")
      helper:   (options.helper || "clone")
      appendTo: (options.appendTo || "#coreon-modal")

  draggableOff: (el)->
    _draggableElement = $(el)
    _draggableElement.off "dragstart"
    _draggableElement.off "dragstop"
