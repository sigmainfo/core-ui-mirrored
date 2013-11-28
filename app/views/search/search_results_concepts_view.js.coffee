#= require environment
#= require views/composite_view
#= require helpers/can
#= require helpers/repository_path
#= require templates/search/search_results_concepts
#= require views/concepts/concept_label_view
#= require models/concept

class Coreon.Views.Search.SearchResultsConceptsView extends Coreon.Views.CompositeView

  className: "search-results-concepts"

  template: Coreon.Templates["search/search_results_concepts"]

  initialize: ->
    super
    @model.on "change", @render, @

  destroy: ->
    @model.off null, null, @

  render: ->
    concepts = @extractConcepts @model.get("hits")[0..9]
    @$el.html @template concepts: concepts, query: @model.query()
    @$("tbody td.label").append (index) ->
      new Coreon.Views.Concepts.ConceptLabelView(id: concepts[index].id).render().$el
    @$("tbody td.super").append (index) ->
      for concept_id, index in concepts[index].superconcept_ids
        new Coreon.Views.Concepts.ConceptLabelView(id: concept_id).render().el
    @

  extractConcepts: (hits) ->
    @stopListening()
    concepts = for hit in hits
      concept = Coreon.Models.Concept.find hit.result.id
      @listenTo  concept, 'change:label', @render
      id               : concept.id
      label            : concept.get 'label'
      superconcept_ids : concept.get 'superconcept_ids'
      score            : hit.score

    concepts.sort ( a, b ) ->
      diff = b.score - a.score
      if diff is 0
        a.label.localeCompare b.label
      else
        diff
