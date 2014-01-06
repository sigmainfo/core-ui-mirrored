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
    @hits = Coreon.Collections.Terms.hits()

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

    @listenTo @hits
            , 'reset'
            , @onHitsReset

  update: ->
    source = @get 'source'
    scope  = @get 'scope'
    terms  =
      if scope is 'hits' and source?
        @hits.lang source
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
    if router instanceof Coreon.Routers.RepositoriesRouter
      if route is 'show'
        @set 'scope', 'all', silent: yes
        @update()

  onHitsReset: ->
    @set 'scope', 'hits', silent: yes
    @update()
