#= require environment
#= require views/concepts/concept_list_view
#= require views/concepts/concept_view
#= require views/concepts/create_concept_view
#= require models/search

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    "concepts/search/(:target/):query" : "search"
    "concepts/create(/:query)" : "create"
    "concepts/:id"    : "show"

  initialize: (options) ->
    @[key] = value for key, value of options

  search: (target, query) ->

    @view.widgets.search.selector.hideHint()
    @view.$("input#coreon-search-query").val decodeURIComponent(query)

    search = new Coreon.Models.Search
      path: "concepts/search"
      query: query
      target: target

    results = new Coreon.Views.Concepts.ConceptListView
      model: search
      collection: @collection
    
    @view.switch results

    search.fetch().done (data) =>
      Coreon.Models.Concept.upsert ( hit.result for hit in data.hits )
      idAttribute = Coreon.Models.Concept::idAttribute
      @app.hits.reset ( id: hit.result[idAttribute], score: hit.score for hit in data.hits )

  show: (id) ->
    screen = new Coreon.Views.Concepts.ConceptView
      model: Coreon.Models.Concept.find id
    @view.switch screen
    @app.hits.reset [ id: id ]

  create: (query) ->
    screen = new Coreon.Views.Concepts.CreateConceptView
      model: new Coreon.Models.Concept
        terms: [ lang: "en", value: query ]
    @view.switch screen

