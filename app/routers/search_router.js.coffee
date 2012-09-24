#= require environment
#= require backbone.queryparams
#= require views/search/search_results_view 
#= require models/search

class Coreon.Routers.SearchRouter extends Backbone.Router

  routes:
    "search": "search"

  initialize: (options) ->
    @[key] = value for key, value of options

  search: (params) ->
    @view.widgets.search.selector.hideHint()
    @view.$("input#coreon-search-query").val params.q

    searches =
      terms: new Coreon.Models.Search
        path: "terms/search"
        query: params.q

      concepts: new Coreon.Models.Search
        path: "concepts/search"
        query: params.q

      tnodes: new Coreon.Models.Search
        path: "tnodes/search"
        query: params.q

    @searchResultsView = new Coreon.Views.Search.SearchResultsView
      model: searches
    @view.switch @searchResultsView

    searches.terms.fetch()
    searches.tnodes.fetch()
    searches.concepts.fetch().done (data) =>
      @concepts.addOrUpdate _(data.hits).pluck "result"

