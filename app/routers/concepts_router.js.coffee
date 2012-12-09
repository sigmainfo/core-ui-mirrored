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
    
    @view.switch results

    search.fetch().done (data) =>
      Coreon.Models.Concept.upsert ( hit.result for hit in data.hits )
      idAttribute = Coreon.Models.Concept::idAttribute
      @app.hits.update ( id: hit.result[idAttribute], score: hit.score for hit in data.hits ) 

  show: (id) ->
    screen = new Coreon.Views.Concepts.ConceptView
      model: Coreon.Models.Concept.find id
    @view.switch screen
    @app.hits.update [ id: id ]
