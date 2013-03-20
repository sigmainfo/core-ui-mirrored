#= require environment
#= require views/concepts/concept_list_view
#= require views/concepts/concept_view
#= require views/concepts/create_concept_view
#= require models/concept_search

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    "concepts/search/(:target/):query" : "search"
    "concepts/create(/:query)" : "create"
    "concepts/create" : "create"
    "concepts/:id"    : "show"

  initialize: (options) ->
    @[key] = value for key, value of options

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

  show: (id) ->
    concept = Coreon.Models.Concept.find id
    screen = new Coreon.Views.Concepts.ConceptView model: concept
    @view.switch screen
    @app.hits.reset [ result: concept ]

  create: (query) ->
    screen = new Coreon.Views.Concepts.CreateConceptView model:
      new Coreon.Models.Concept
    if query
      screen.model.get("terms").push
        lang: "en"
        value: query
    @view.switch screen
