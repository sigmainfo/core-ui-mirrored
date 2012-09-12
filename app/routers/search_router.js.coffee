#= require environment
#= require backbone.queryparams
#= require views/main/search_results_view 
#= require models/search

class Coreon.Routers.SearchRouter extends Backbone.Router

  routes:
    "search": "search"

  initialize: (options) ->
    @[key] = value for key, value of options

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

      tnodes: new Coreon.Models.Search
        path: "tnodes/search"
        params:
          "search[query]": params.q

    @searchResultsView = new Coreon.Views.Main.SearchResultsView
      el: @view.$("#coreon-main")
      model: searches

    @searchResultsView.render()

    searches.terms.fetch()
    searches.tnodes.fetch()
    searches.concepts.fetch().done (data) =>
      @concepts.addOrUpdate _(data.hits).pluck "result"
