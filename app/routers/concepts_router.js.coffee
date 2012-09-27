#= require environment
#= require backbone.queryparams
#= require views/concepts/concept_list_view
#= require views/concepts/concept_view
#= require models/search

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    "concepts/search" : "search"
    "concepts/:id"    : "show"

  initialize: (options) ->
    @[key] = value for key, value of options

  search: (params) ->
    @view.widgets.search.selector.hideHint()
    @view.$("input#coreon-search-query").val params.q

    search = new Coreon.Models.Search
      path: "concepts/search"
      query: params.q
      target: params.t

    results = new Coreon.Views.Concepts.ConceptListView
      model: search
      collection: @collection
    
    @view.switch results.render()

    search.fetch()

  show: (id) ->
    screen = new Coreon.Views.Concepts.ConceptView
      model: @collection.getOrFetch id
    @view.switch screen
