#= require environment
#= require helpers/render
#= require templates/concepts/_caption
#= require templates/concepts/new_concept

class Coreon.Views.Concepts.NewConceptView extends Backbone.View

  className: "concept new"

  template: Coreon.Templates["concepts/new_concept"]

  render: ->
    @$el.html @template concept: @model
    @
