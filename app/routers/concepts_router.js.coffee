#= require environment
#= require backbone.queryparams
#= require views/concepts/concept_list_view
#= require models/search

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    "concepts/search": "search"

  initialize: (options) ->
    @[key] = value for key, value of options

  search: (params) ->
    @view.widgets.search.selector.hideHint()
    @view.$("input#coreon-search-query").val params.q

    longParams = "search[query]": params.q

    if params.t
      longParams["search[target]"] = params.t

    search = new Coreon.Models.Search
      path: "concepts/search"
      params: longParams
    
    @view.switch new Coreon.Views.Concepts.ConceptListView
      model: search
      collection: @collection

    search.fetch()
