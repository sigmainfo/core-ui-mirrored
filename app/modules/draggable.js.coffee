#= require environment
#= require jquery.ui.draggable

# make view element draggable
# Options can be overwritten via attribute and are the same as for
# JQueryUI.draggable.
#
# To overwrite the element to be dragged, set @draggableElement before
# initializing. For Example:
#
# class Coreon.View.Something extends Backbone.View
#   Coreon.Modules.include @, Coreon.Modules.Draggable
#   initialize: ->
#     @draggableElement = @$(".draghandle")
#     draggable()
#

Coreon.Modules.Draggable =

  _draggable_startDragging: ->
    @draggableElement.addClass "ui-draggable-dragged"

  _draggable_stopDragging: ->
    @draggableElement.removeClass "ui-draggable-dragged"

  draggableOn: (options={}, verbose=no)->
    @draggableElement ||= @$el
    @draggableElement = $(@draggableElement)

    # events
    @draggableElement.on "dragstart", =>@_draggable_startDragging()
    @draggableElement.on "dragstop", =>@_draggable_stopDragging()

    # jquery.ui.draggable magic
    @draggableElement.draggable
      revert:   (options.revert || "invalid")
      helper:   (options.helper || "clone")
      appendTo: (options.appendTo || "#coreon-modal")

    console.log @draggableElement, @draggableElement.data() if verbose

  draggableOff: ->
    @draggableElement.off "dragstart"
    @draggableElement.off "dragstop"
