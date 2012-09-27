#= require environment
#= require views/composite_view
#= require templates/concepts/concept

class Coreon.Views.Concepts.ConceptView extends Coreon.Views.CompositeView

  className: "concept"

  template: Coreon.Templates["concepts/concept"]

  render: ->
    @$el.html @template concept: @model
    @
