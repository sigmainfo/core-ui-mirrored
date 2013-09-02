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

  _droppable_onEnter: (el, cssClass) ->
    $(el).addClass cssClass

  _droppable_onLeave: (el, cssClass) ->
    $(el).removeClass cssClass


  droppableOn: (el, dragElClass="ui-droppable-hovered", options={})->
    _dropzone = $(el)

    defaults =
      greedy: true
      activeClass: "ui-state-highlight"
      hoverClass: "ui-state-hovered"
      tolerance: "pointer"
      over: (evt, ui) => @_droppable_onEnter(ui.helper, dragElClass)
      out: (evt, ui) => @_droppable_onLeave(ui.helper, dragElClass)

    options = _.extend defaults, options
    _dropzone.droppable options
    _dropzone.droppable "enable"

  droppableOff: (el)->
    _dropzone = $(el)
    _dropzone.droppable "disable"

