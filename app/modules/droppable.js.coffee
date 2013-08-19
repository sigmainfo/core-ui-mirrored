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
    ui.helper.addClass @dragElClass

  _droppable_onLeave: (evt, ui) ->
    ui.helper.removeClass @dragElClass


  droppableOn: (el, @dragElClass="ui-droppable-hovered", options={})->
    _dropzone = $(el)

    defaults =
      activeClass: "ui-state-highlight"
      hoverClass: "ui-state-hovered"
      tolerance: "pointer"
      over: (evt, ui) => @_droppable_onEnter(evt, ui)
      out: (evt, ui) => @_droppable_onLeave(evt, ui)

    options = _.extend defaults, options
    _dropzone.droppable options

  droppableOff: (el)->
    _dropzone = $(el)
    _dropzone.droppable "disable"

