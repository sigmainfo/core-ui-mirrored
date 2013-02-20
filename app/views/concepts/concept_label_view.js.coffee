#= require environment
#= require views/simple_view
#= require models/concept

class Coreon.Views.Concepts.ConceptLabelView extends Coreon.Views.SimpleView

  tagName: "a"

  className: "concept-label"

  initialize: (options = {}) ->
    @model =  if options.model?
        options.model
      else
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

  render: ->
    @$el.toggleClass "hit", @model.has "hit"
    @$el.attr "href", "/concepts/#{@model.id}"
    @$el.html @model.escape "label"
    @
