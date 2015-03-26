#= require environment
#= require templates/concepts/shared/associative_relations/show
#= require templates/concepts/_info
#= require views/concepts/concept_label_view

class Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView extends Backbone.View

  tagName: "tr"

  className: "relation-type"

  template: Coreon.Templates["concepts/shared/associative_relations/show"]

  initialize: ->
    @relations = _(@model.relations).map (r) -> { concept: Coreon.Models.Concept.find(r.id), info: r.info }

  render: ->
    @$el.html @template title: @model.relationType.key, icon: @model.relationType.icon
    _(@relations).each (relation) =>
      relationElement = $("<li>")
      relationElement.append @createConceptLabel(relation.concept)
      relationElement.append $ Coreon.Templates["concepts/info"](data: relation.info)
      @$el.find('td.relations ul').append relationElement
    @

  createConceptLabel: (concept) ->
    label = new Coreon.Views.Concepts.ConceptLabelView model: concept
    label.render().$el