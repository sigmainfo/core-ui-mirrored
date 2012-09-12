#= require environment

class Coreon.Views.Concepts.ConceptLabelView extends Backbone.View

  tagName: "a"

  className: "concept-label"

  initialize: (id) ->
    @model = Coreon.application.concepts.getOrFetch id
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
