#= require environment
#= require jquery.ui.draggable
#= require views/simple_view
#= require models/concept
#= require helpers/repository_path

class Coreon.Views.Concepts.ConceptLabelView extends Coreon.Views.SimpleView

  tagName: "a"

  className: "concept-label"

  events:
    "dragstart": "onStartDragging"
    "dragstop":  "onStopDragging"

  initialize: (options = {}) ->
    @model = if options.model?
        options.model
      else #TODO: remove, too much magic
        Coreon.Models.Concept.find options.id

    @model.on "change", @render, @

  appendTo: (target) ->
    @delegateEvents()
    @$el.appendTo target

  dispose: ->
    @model.off null, null, @

  destroy: ->
    @remove()
    @dispose()

  onStartDragging: ->
    @$el.addClass "ui-draggable-dragged"

  onStopDragging: ->
    @$el.removeClass "ui-draggable-dragged"


  render: ->
    @$el.draggable
      revert: "invalid"
      helper: "clone"
      appendTo: "#coreon-modal"
    @$el.toggleClass "hit", @model.has "hit"
    @$el.attr "href", Coreon.Helpers.repositoryPath("concepts/#{@model.id}")
    @$el.html @model.escape "label"
    @
