#= require environment
#= require views/main/search_results_terms_view
#= require views/main/search_results_concepts_view

class Coreon.Views.Main.SearchResultsView extends Backbone.View

  initialize: ->
    @terms = new Coreon.Views.Main.SearchResultsTermsView
      model: @model.terms
    @concepts = new Coreon.Views.Main.SearchResultsConceptsView
      model: @model.concepts

  render: ->
    @$el.empty()
    @terms.render().$el.appendTo @$el
    @concepts.render().$el.appendTo @$el
    @
