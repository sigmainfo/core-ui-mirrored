#= require environment
#= require models/repository
#= require models/search
#= require models/concept_search
#= require views/repositories/repository_view
#= require views/search/search_results_view

class Coreon.Routers.RepositoriesRouter extends Backbone.Router

  routes:
    "": "root"

  _bindRoutes: ->
    super
    @route /^([0-9a-f]{24})$/, "show"
    @route /^([0-9a-f]{24})\/search\/([^/]+)/, "search"

  initialize: (@view) ->

  root: ->
    if repo = @view.repository()
      @navigate repo.id, trigger: yes, replace: yes
    else
      @navigate "logout"

  show: (id) ->
    if repo = @view.repository id
      @navigate repo.id
      screen = new Coreon.Views.Repositories.RepositoryView model: repo
      @view.switch screen
    else
      @navigate "", trigger: yes, replace: yes
   
  search: (id, query) ->
    @view.repository id

    query = decodeURIComponent(query)
    
    # @view.widgets.search.selector.hideHint()
    # @view.$("input#coreon-search-query").val query
    @view.query query

    terms = new Coreon.Models.Search
        path: "terms/search"
        query: query
    concepts = new Coreon.Models.ConceptSearch
        path: "concepts/search"
        query: query

    searchResultsView = new Coreon.Views.Search.SearchResultsView
      models:
        terms: terms
        concepts: concepts
    @view.switch searchResultsView

    terms.fetch()
    concepts.fetch()
