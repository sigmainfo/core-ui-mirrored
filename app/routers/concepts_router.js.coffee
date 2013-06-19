#= require environment
#= require views/concepts/concept_view
#= require views/concepts/new_concept_view
#= require models/concept_search
#= require views/concepts/concept_list_view

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    ":repository/concepts/new(/terms/:lang/:value)" : "new"
    ":repository/concepts/search/(:target/):query"  : "search"

  _bindRoutes: ->
    super
    @route /^([0-9a-f]{24})\/concepts\/([0-9a-f]{24})$/,       "show"

  initialize: (@view) ->

  show: (repository, id) ->
    @view.repository repository
    concept = Coreon.Models.Concept.find id
    @view.switch new Coreon.Views.Concepts.ConceptView
      model: concept
    Coreon.Models.Hit.collection().reset [ result: concept ]

  new: (repository, lang, value) ->
    @view.repository repository
    if true #Coreon.application?.session.ability.can "create", Coreon.Models.Concept
      attrs = {}
      attrs.terms = [ lang: lang, value: value ] if value?
      concept = new Coreon.Models.Concept attrs
      @view.switch new Coreon.Views.Concepts.NewConceptView
        model: concept
      Coreon.Models.Hit.collection().reset [ result: concept ]
    else
      Backbone.history.navigate "/", trigger: true

  search: (repository, target, query) ->
    @view.repository repository
    query = decodeURIComponent(query)
    @view.query query

    search = new Coreon.Models.ConceptSearch
      path: "concepts/search"
      query: query
      target: target

    @view.switch new Coreon.Views.Concepts.ConceptListView
      model: search
      collection: @collection

    search.fetch()

