#= require environment
#= require views/search/search_results_view 
#= require models/search
#= require models/concept_search

class Coreon.Routers.SearchRouter extends Backbone.Router

  routes:
    "search/:query": "search"

  initialize: (options) ->
    @[key] = value for key, value of options

  search: (query) ->

    query = decodeURIComponent(query)
    
    @view.widgets.search.selector.hideHint()
    @view.$("input#coreon-search-query").val query

    searches =
      terms: new Coreon.Models.Search
        path: "terms/search"
        query: query

      concepts: new Coreon.Models.ConceptSearch
        path: "concepts/search"
        query: query

      tnodes: new Coreon.Models.Search
        path: "taxonomy_nodes/search"
        query: query

    @searchResultsView = new Coreon.Views.Search.SearchResultsView
      models: searches
    @view.switch @searchResultsView

    searches.terms.fetch()
    searches.tnodes.fetch()
    searches.concepts.fetch()
