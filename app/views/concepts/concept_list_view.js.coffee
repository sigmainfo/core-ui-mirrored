#= require environment
#= require views/composite_view
#= require templates/concepts/concept_list
#= require views/concepts/concept_list_item_view
#= require models/concept

class Coreon.Views.Concepts.ConceptListView extends Coreon.Views.CompositeView

  className: "concept-list"

  template: Coreon.Templates["concepts/concept_list"]

  initialize: ->
    super
    @model.on "change", @render, @

  render: () ->
    @$el.html @template()
    for hit in @model.get "hits"
      model = Coreon.Models.Concept.upsert hit.result
      item = new Coreon.Views.Concepts.ConceptListItemView
        model: model
      @append ".concepts", item.render()
    super
