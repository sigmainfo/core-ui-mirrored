#= require environment
#= require views/simple_view
#= require models/concept
#= require helpers/repository_path
#= require modules/draggable

class Coreon.Views.Concepts.ConceptLabelView extends Coreon.Views.SimpleView

  Coreon.Modules.include @, Coreon.Modules.Draggable

  tagName: "a"

  className: "concept-label"

  initialize: (options = {}) ->
    @model = if options.model?
        options.model
      else #TODO: remove, too much magic
        Coreon.Models.Concept.find options.id

    @model.on "change", @render, @
    @draggableOn()

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
    @$el.attr "href", Coreon.Helpers.repositoryPath("concepts/#{@model.id}")
    @$el.html @model.escape "label"
    @
