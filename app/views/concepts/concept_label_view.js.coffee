#= require environment
#= require views/simple_view
#= require models/concept
#= require helpers/repository_path

class Coreon.Views.Concepts.ConceptLabelView extends Coreon.Views.SimpleView

  tagName: "a"

  className: "concept-label"

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

  render: ->
    #repo = Backbone.history.fragment.split("/")[0]
    @$el.toggleClass "hit", @model.has "hit"
    @$el.attr "href", Coreon.Helpers.repositoryPath("concepts", @model.id)
    @$el.html @model.escape "label"
    @
