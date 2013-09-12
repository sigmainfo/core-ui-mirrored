#= require environment
#= require views/composite_view
#= require helpers/can
#= require helpers/repository_path
#= require templates/search/search_results_concepts
#= require views/concepts/concept_label_view

class Coreon.Views.Search.SearchResultsConceptsView extends Coreon.Views.CompositeView

  className: "search-results-concepts"

  template: Coreon.Templates["search/search_results_concepts"]

  initialize: ->
    super
    @model.on "change", @render, @

  destroy: ->
    @model.off null, null, @

  render: ->
    concepts = @extractConcepts(@model.get("hits")[0..9])
    @$el.html @template concepts: concepts, query: @model.query()
    @$("tbody td.label").append (index) ->
      new Coreon.Views.Concepts.ConceptLabelView(id: concepts[index].id).render().$el
    @$("tbody td.super").append (index) ->
      for concept_id, index in concepts[index].superconcept_ids
        new Coreon.Views.Concepts.ConceptLabelView(id: concept_id).render().el
    @

  extractConcepts: (hits) ->
    _(hits).pluck("result").map (result) ->
      id: result.id
      label: _(result.properties)?.find((prop)-> prop.key == "label")?.value
      superconcept_ids: result.superconcept_ids
