#= require environment
#= require views/composite_view
#= require views/concepts/concept_list_item_view

class Coreon.Views.Concepts.ConceptListView extends Coreon.Views.CompositeView

  className: "concept-list"

  render: () ->
    subview.destroy() for subview in @subviews
    for hit in @model.get "hits"
      item = new Coreon.Views.Concepts.ConceptListItemView
        model: @concepts.get hit.result._id
      @append item.render()
    @
