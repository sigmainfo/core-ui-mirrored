#= require environment
#= require helpers/link_to
#= require templates/main/search_results_terms

class Coreon.Views.Main.SearchResultsTermsView extends Backbone.View

  className: "search-results-terms"

  template: Coreon.Templates["main/search_results_terms"]

  initialize: ->
    @model.on "change", @render, @

  render: ->
    @$el.html @template terms: _(@model.get "hits").pluck("result")[0..9]
    @
