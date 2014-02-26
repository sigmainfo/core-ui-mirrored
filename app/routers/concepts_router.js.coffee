#= require environment
#= require models/concept
#= require models/concept_search

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  initialize: (@app) ->
    @hits = Coreon.Collections.Hits.collection()

  BASE = '([0-9a-f]{24})/concepts'

  routes:
    '([0-9a-f]{24})' : 'show'
    'search/([^/]+)' : 'search'

  route: (route, name, callback) ->
    pattern = "^#{BASE}/#{route}$"
    matcher = new RegExp(pattern)
    callback ?= @[name]
    super matcher, name, (repositoryId, params...) =>
      @selectRepository repositoryId
      callback.apply @, params

  selectRepository: (id) ->
    @app.selectRepository id

  show: (id) ->
    concept = Coreon.Models.Concept.find id, fetch: yes
    selection = new Backbone.Collection [concept]
    @hits.reset selection.map( (concept) -> result: concept )
    @app.set
      selection: selection
      scope: 'pager'

  # _bindRoutes: ->
  #   super
  #   show_concept =    new RegExp('^([0-9a-f]{24})/concepts/([0-9a-f]{24})$')
  #   new_concept =     new RegExp('^([0-9a-f]{24})/concepts/new(?:/terms/([^/]+)/([^/]+))?$')
  #   new_with_parent = new RegExp('^([0-9a-f]{24})/concepts/new/parent/([0-9a-f]{24})?$')
  #   search_concept =  new RegExp('^([0-9a-f]{24})/concepts/search/(?:([^/]+)/)?([^/]+)$')
  #   @route show_concept,    "show"
  #   @route new_concept,     "new"
  #   @route new_with_parent, "newWithParent"
  #   @route search_concept,  "search"
  #
  # newWithParent: (repository, parent_id) ->
  #   repo = @view.repository repository
  #   roles = repo?.get "user_roles"
  #   if roles and "maintainer" in roles
  #     attrs =
  #       superconcept_ids: [parent_id]
  #     concept = new Coreon.Models.Concept attrs
  #     Coreon.Collections.Hits.collection().reset [ result: concept ]
  #   else
  #     Backbone.history.navigate "/", trigger: true
  #
  # new: (repository, lang, value) ->
  #   repo = @view.repository repository
  #   roles = repo?.get "user_roles"
  #   if roles and "maintainer" in roles
  #     attrs = {}
  #     attrs.terms = [ lang: lang, value: value ] if value?
  #     concept = new Coreon.Models.Concept attrs
  #     Coreon.Collections.Hits.collection().reset [ result: concept ]
  #   else
  #     Backbone.history.navigate "/", trigger: true
  #
  # search: (repository, target, query) ->
  #   @view.repository repository
  #   query = decodeURIComponent(query)
  #   @view.query query
  #
  #   search = new Coreon.Models.ConceptSearch
  #     query: query
  #     target: target
  #
  #   search.fetch()
