#= require environment
#= require views/simple_view
#= require models/concept

class Coreon.Views.Concepts.ConceptLabelView extends Coreon.Views.SimpleView

  tagName: "a"

  className: "concept-label"

  initialize: (idOrOptions) ->
    switch typeof idOrOptions
      when "string"
        @model = Coreon.Models.Concept.find idOrOptions
      when "object"
        @model = idOrOptions.model

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
    @$el.attr "href", "/concepts/#{@model.id}"
    @$el.html @model.label()
    @
