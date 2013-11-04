#= require environment
#= require models/concept
#= require models/concept_search
#= require views/concepts/concept_view
#= require views/concepts/new_concept_view
#= require views/concepts/concept_list_view

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  _bindRoutes: ->
    super
    show_concept =    new RegExp('^([0-9a-f]{24})/concepts/([0-9a-f]{24})$')
    new_concept =     new RegExp('^([0-9a-f]{24})/concepts/new(?:/terms/([^/]+)/([^/]+))?$')
    new_with_parent = new RegExp('^([0-9a-f]{24})/concepts/new/parent/([0-9a-f]{24})?$')
    search_concept =  new RegExp('^([0-9a-f]{24})/concepts/search/(?:([^/]+)/)?([^/]+)$')
    @route show_concept,    "show"
    @route new_concept,     "new"
    @route new_with_parent, "newWithParent"
    @route search_concept,  "search"


  initialize: (@view) ->

  show: (repository, id) ->
    @view.repository repository
    concept = Coreon.Models.Concept.find id, fetch: yes
    @view.switch new Coreon.Views.Concepts.ConceptView
      model: concept
    Coreon.Collections.Hits.collection().reset [ result: concept ]

  newWithParent: (repository, parent_id) ->
    repo = @view.repository repository
    roles = repo?.get "user_roles"
    if roles and "maintainer" in roles
      attrs =
        superconcept_ids: [parent_id]
      concept = new Coreon.Models.Concept attrs
      @view.switch new Coreon.Views.Concepts.NewConceptView
        model: concept
    else
      Backbone.history.navigate "/", trigger: true

  new: (repository, lang, value) ->
    repo = @view.repository repository
    roles = repo?.get "user_roles"
    if roles and "maintainer" in roles
      attrs = {}
      attrs.terms = [ lang: lang, value: value ] if value?
      concept = new Coreon.Models.Concept attrs
      @view.switch new Coreon.Views.Concepts.NewConceptView
        model: concept
      console.log "reset"
      Coreon.Collections.Hits.collection().reset [ result: concept ]
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

    search.fetch()
