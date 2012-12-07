#= require environment
#= require views/composite_view
#= require templates/concepts/concept_list_item
#= require views/concepts/concept_label_view

class Coreon.Views.Concepts.ConceptListItemView extends Coreon.Views.CompositeView

  tagName: "tbody"

  className: "concept-list-item"

  template: Coreon.Templates["concepts/concept_list_item"]

  render: () ->
    @clear()
    terms = _(@model.get "terms")?.groupBy "lang" if @model.get("terms").length > 0
    @$el.html @template
      concept: @model
      definition: _(@model.get "properties")?.find (p) -> p.key == "definition"
      terms: terms or null
    @renderLabel()
    @renderSuperconcepts() if @model.get "super_concept_ids"
    @

  renderLabel: ->
    label = new Coreon.Views.Concepts.ConceptLabelView model: @model
    @$("td.label").append label.render().$el
    @subviews.push label

  renderSuperconcepts: ->
    for superconceptId in @model.get "super_concept_ids"
      label = new Coreon.Views.Concepts.ConceptLabelView superconceptId
      @$("td.super").append label.render().$el
      @subviews.push label
