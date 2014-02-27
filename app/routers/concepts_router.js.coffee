#= require environment
#= require models/concept
#= require models/concept_search
#= require helpers/can

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  initialize: (@app) ->
    @hits = Coreon.Collections.Hits.collection()

  BASE = '([0-9a-f]{24})/concepts'

  routes:
    '([0-9a-f]{24})'                  : 'show'
    'search/(?:([^/]+)/)?([^/]+)'     : 'search'
    'new'                             : 'new'
    'new/broader/([0-9a-f]{24})'      : 'newWithSuper'
    'new/terms/([^/]+)/([^/]+)'       : 'newWithTerm'

  route: (route, name, callback) ->
    pattern = "^#{BASE}/#{route}$"
    matcher = new RegExp(pattern)
    callback ?= @[name]
    super matcher, name, (repositoryId, params...) =>
      @selectRepository repositoryId
      callback.apply @, params

  selectRepository: (id) ->
    @app.selectRepository id

  can: Coreon.Helpers.can

  updateSelection: (concepts) ->
    scope = if concepts.length > 1 then 'index' else 'pager'
    selection = new Backbone.Collection concepts
    @hits.reset selection.map( (concept) -> result: concept )
    @app.set
      scope: scope
      selection: selection

  show: (id) ->
    concept = Coreon.Models.Concept.find id, fetch: yes
    @updateSelection [concept]

  search: (target, query) ->
    query = decodeURIComponent(query)
    @app.set 'query', query
    search = new Coreon.Models.ConceptSearch
      target: target
      query: query
    search.fetch()
      .done =>
        results = @hits.pluck('result')
        selection = new Backbone.Collection results
        @app.set
          selection: selection
          scope: 'index'

  new: (attrs) ->
    if @can 'create', Coreon.Models.Concept
      concept = new Coreon.Models.Concept attrs
      @updateSelection [concept]
    else
      repository = @app.get('repository')
      @navigate repository.id, trigger: yes, replace: yes

  newWithSuper: (superId) ->
    @new superconcept_ids: [superId]

  newWithTerm: (lang, value) ->
    value = decodeURIComponent(value)
    @new terms: [lang: lang, value: value]
