#= require environment
#= require templates/main/search_results_terms
#= require views/concepts/concept_label_view

class Coreon.Views.Main.SearchResultsTermsView extends Backbone.View

  className: "search-results-terms"

  template: Coreon.Templates["main/search_results_terms"]

  initialize: ->
    @model.on "change", @render, @

  render: ->
    terms = _(@model.get "hits").pluck("result")[0..9]
    @$el.html @template terms: terms
    @$("td.concept").append (index) ->
      new Coreon.Views.Concepts.ConceptLabelView(terms[index].concept_id).render().$el
    @
