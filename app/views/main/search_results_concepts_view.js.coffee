#= require environment
#= require templates/main/search_results_concepts
#= require views/concepts/concept_label_view

class Coreon.Views.Main.SearchResultsConceptsView extends Backbone.View

  className: "search-results-concepts"

  template: Coreon.Templates["main/search_results_concepts"]

  initialize: ->
    @model.on "change", @render, @

  destroy: ->
    @model.off null, null, @

  render: ->
    concepts = @extractConcepts(@model.get("hits")[0..9])
    @$el.html @template concepts: concepts, query: @model.query()
    @$("tbody td.label").append (index) ->
      new Coreon.Views.Concepts.ConceptLabelView(concepts[index].id).render().$el
    @$("tbody td.super").append (index) ->
      for concept_id, index in concepts[index].super_concept_ids
        new Coreon.Views.Concepts.ConceptLabelView(concept_id).render().el
    @

  extractConcepts: (hits) ->
    _(hits).pluck("result").map (result) ->
      id: result._id
      label: _(result.properties)?.find((prop)-> prop.key == "label")?.value
      super_concept_ids: result.super_concept_ids
