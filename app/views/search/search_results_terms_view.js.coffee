#= require environment
#= require views/composite_view
#= require templates/main/search_results_terms
#= require views/concepts/concept_label_view

class Coreon.Views.Search.SearchResultsTermsView extends Coreon.Views.CompositeView

  className: "search-results-terms"

  template: Coreon.Templates["main/search_results_terms"]

  initialize: ->
    super
    @model.on "change", @render, @

  render: ->
    terms = _(@model.get "hits").pluck("result")[0..9]
    @$el.html @template terms: terms
    @$("td.concept").append (index) ->
      new Coreon.Views.Concepts.ConceptLabelView(terms[index].concept_id).render().$el
    @
