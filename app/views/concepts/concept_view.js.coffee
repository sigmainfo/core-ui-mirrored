#= require environment
#= require views/composite_view
#= require templates/concepts/concept
#= require views/concepts/concept_tree_view
#= require views/properties/properties_view
#= require views/terms/terms_view

class Coreon.Views.Concepts.ConceptView extends Coreon.Views.CompositeView

  className: "concept"

  template: Coreon.Templates["concepts/concept"]

  initialize: ->
    super
    @tree = new Coreon.Views.Concepts.ConceptTreeView model: @model
    @props = new Coreon.Views.Properties.PropertiesView model: @model
    @terms = new Coreon.Views.Terms.TermsView model: @model

  render: ->
    @$el.html @template concept: @model
    @append @tree, @props, @terms
    super
