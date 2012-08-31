#= require environment
#= require backbone.queryparams
#= require views/main/search_results_view 
#= require models/search

class Coreon.Routers.SearchRouter extends Backbone.Router

  routes:
    "search": "search"

  initialize: (@view) ->

  search: (params) ->
    searches =
      terms: new Coreon.Models.Search
        path: "terms/search"
        params:
          "search[query]": params.q

      concepts: new Coreon.Models.Search
        path: "concepts/search"
        params:
          "search[query]": params.q

    @searchResultsView = new Coreon.Views.Main.SearchResultsView
      el: @view.$("#coreon-main")
      model: searches

    @searchResultsView.render()

    searches.terms.fetch()
    searches.concepts.fetch()
