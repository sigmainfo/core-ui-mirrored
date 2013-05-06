#= require environment
#= require views/concepts/root_view
#= require views/concepts/concept_view
#= require views/concepts/new_concept_view
#= require models/concept_search
#= require views/concepts/concept_list_view

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    ""                                  : "root"
    "concepts/new(/terms/:lang/:value)" : "new"
    "concepts/search/(:target/):query"  : "search"

  _bindRoutes: ->
    super
    @route /^concepts\/([0-9a-f]{24})$/,       "show"
    @route /^concepts\/([0-9a-f]{24})\/edit$/, "edit"

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

  edit: (id) ->
    #TODO: if Coreon.application?.session.ability.can "edit", Coreon.Models.Concept
    concept = Coreon.Models.Concept.find id
    @view.switch new Coreon.Views.Concepts.EditConceptView
      model: concept
    @app.hits.reset [ result: concept ]

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

