#= require environment
#= require collections/terms
#= require routers/repositories_router
#= require routers/concepts_router

class Coreon.Models.TermList extends Backbone.Model

  defaults: ->
    source: null
    target: null
    scope: 'hits'

  initialize: ->
    @terms = new Coreon.Collections.Terms
    @updateSource()
    @stopListening()

    @listenTo @
            , 'change:source change:scope'
            , @update

    @listenTo Coreon.application.repositorySettings()
            , 'change:sourceLanguage'
            , @updateSource

    @listenTo Backbone.history
            , 'route'
            , @onRoute

  update: ->
    source = @get 'source'
    scope  = @get 'scope'
    terms  =
      if scope is 'hits' and source?
        Coreon.Collections.Terms.hits().lang source
      else
        []
    @terms.reset terms
    if scope is 'all' and source?
      @terms
        .fetch( source )
        .done( => @trigger 'update', @terms, @attributes )
    @trigger 'update', @terms, @attributes

  updateSource: ->
    @set 'source', Coreon.application.sourceLang()

  onRoute: ( router, route, params ) ->
    switch
      when router instanceof Coreon.Routers.RepositoriesRouter
        @set 'scope', 'all' if route is 'show'
      when router instanceof Coreon.Routers.ConceptsRouter
        @set 'scope', 'hits' if route is 'search'
