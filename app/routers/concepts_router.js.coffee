#= require environment
#= require views/concepts/root_view
#= require views/concepts/concept_list_view
#= require views/concepts/concept_view
#= require views/concepts/create_concept_view
#= require models/concept_search

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    ""                                 : "root"
    "concepts/:id"                     : "show"
    "concepts/new"                     : "create"
    "concepts/search/(:target/):query" : "search"

  initialize: (options) ->
    @[key] = value for key, value of options

  root: ->
    @view.switch new Coreon.Views.Concepts.RootView
    @app.hits.reset []

  show: (id) ->
    concept = Coreon.Models.Concept.find id
    @view.switch new Coreon.Views.Concepts.ConceptView
      model: concept
    @app.hits.reset [ result: concept ]

  create: ->
    screen = new Coreon.Views.Concepts.CreateConceptView model:
      new Coreon.Models.Concept
    @view.switch screen
    @app.hits.reset [ result: screen.model ]

  search: (target, query) ->

    @view.widgets.search.selector.hideHint()
    @view.$("input#coreon-search-query").val decodeURIComponent(query)

    search = new Coreon.Models.ConceptSearch
      path: "concepts/search"
      query: query
      target: target

    results = new Coreon.Views.Concepts.ConceptListView
      model: search
      collection: @collection
    
    @view.switch results

    search.fetch()

