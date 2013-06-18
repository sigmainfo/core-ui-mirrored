#= require environment
#= require views/concepts/concept_view
#= require views/concepts/new_concept_view
#= require models/concept_search
#= require views/concepts/concept_list_view

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    "concepts/new(/terms/:lang/:value)" : "new"
    "concepts/search/(:target/):query"  : "search"

  _bindRoutes: ->
    super
    @route /^concepts\/([0-9a-f]{24})$/,       "show"

  initialize: (@view) ->

  show: (id) ->
    concept = Coreon.Models.Concept.find id
    @view.switch new Coreon.Views.Concepts.ConceptView
      model: concept
    @app.hits.reset [ result: concept ]

  new: (lang, value) ->
    if Coreon.application?.session.ability.can "create", Coreon.Models.Concept
      attrs = {}
      attrs.terms = [ lang: lang, value: value ] if value?
      concept = new Coreon.Models.Concept attrs
      @view.switch new Coreon.Views.Concepts.NewConceptView
        model: concept
      @app.hits.reset [ result: concept ]
    else
      Backbone.history.navigate "/", trigger: true

  search: (target, query) ->
    @view.widgets.search.selector.hideHint()
    @view.$("input#coreon-search-query").val decodeURIComponent(query)

    search = new Coreon.Models.ConceptSearch
      path: "concepts/search"
      query: query
      target: target

    @view.switch new Coreon.Views.Concepts.ConceptListView
      model: search
      collection: @collection

    search.fetch()

