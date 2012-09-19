#= require environment
#= require views/composite_view
#= require templates/concepts/concept_list
#= require views/concepts/concept_list_item_view

class Coreon.Views.Concepts.ConceptListView extends Coreon.Views.CompositeView

  tagName: "table"

  className: "concept-list"

  template: Coreon.Templates["concepts/concept_list"]

  initialize: ->
    super()
    @model.on "change", @render, @

  render: () ->
    @clear()
    @$el.html @template()
    for hit in @model.get "hits"
      @options.collection.addOrUpdate hit.result
      item = new Coreon.Views.Concepts.ConceptListItemView
        model: @options.collection.get hit.result._id
      @append item.render()
    @
