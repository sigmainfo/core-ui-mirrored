#= require environment
#= require templates/concepts/shared/associative_relations/show
#= require views/concepts/concept_label_list_view

class Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView extends Backbone.View

  tagName: "tr"

  className: "relation-type"

  template: Coreon.Templates["concepts/shared/associative_relations/show"]

  initialize: ->
    @relations = _(@model.relations).map (r) -> Coreon.Models.Concept.find r.id

  render: ->
    @$el.html @template title: @model.relationType.key, icon: @model.relationType.icon
    relationsList = new Coreon.Views.Concepts.ConceptLabelListView
      models: @relations
    relationsList.render()
    @$el.find('td.relations').append relationsList.$el
    @