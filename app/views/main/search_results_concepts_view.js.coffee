#= require environment
#= require helpers/link_to
#= require templates/main/search_results_concepts

class Coreon.Views.Main.SearchResultsConceptsView extends Backbone.View

  className: "search-results-concepts"

  template: Coreon.Templates["main/search_results_concepts"]

  initialize: ->
    @model.on "change", @render, @

  destroy: ->
    @model.off null, null, @

  render: ->
    @$el.html @template concepts: @extractConcepts(@model.get("hits")[0..9])
    @

  extractConcepts: (hits) ->
    _(hits).pluck("result").map (result) ->
      id: result._id
      label: _(result.properties).find((prop)-> prop.key == "label").value
      super_concept_ids: result.super_concept_ids

