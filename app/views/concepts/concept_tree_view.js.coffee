#= require environment
#= require views/composite_view
#= require templates/concepts/concept_tree
#= require views/concepts/concept_label_view

class Coreon.Views.Concepts.ConceptTreeView extends Coreon.Views.CompositeView

  className: "concept-tree"

  template: Coreon.Templates["concepts/concept_tree"]

  render: ->
    @$el.html @template concept: @model
    for id in @model.get "super_concept_ids"
      @append ".super", new Coreon.Views.Concepts.ConceptLabelView id
    for id in @model.get "sub_concept_ids"
      @append ".sub", new Coreon.Views.Concepts.ConceptLabelView id
    super
