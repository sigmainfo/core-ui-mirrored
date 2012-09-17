#= require environment
#= require views/composite_view
#= require templates/concepts/concept_list_item
#= require views/concepts/concept_label_view

class Coreon.Views.Concepts.ConceptListItemView extends Coreon.Views.CompositeView

  className: "concept-list-item"

  template: Coreon.Templates["concepts/concept_list_item"]

  render: () ->
    subview.destroy() for subview in @subviews
    @$el.html @template concept: @model
    @prepend new Coreon.Views.Concepts.ConceptLabelView(model: @model).render()
    @
