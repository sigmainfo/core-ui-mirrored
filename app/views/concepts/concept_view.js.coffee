#= require environment
#= require views/composite_view
#= require templates/concepts/concept
#= require views/concepts/concept_tree_view

class Coreon.Views.Concepts.ConceptView extends Coreon.Views.CompositeView

  className: "concept"

  template: Coreon.Templates["concepts/concept"]

  initialize: ->
    super
    @tree = new Coreon.Views.Concepts.ConceptTreeView model: @model

  render: ->
    @$el.html @template concept: @model
    @append @tree
    super
