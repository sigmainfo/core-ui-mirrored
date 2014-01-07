#= require environment
#= require collections/terms
#= require routers/repositories_router
#= require routers/concepts_router

class Coreon.Models.TermList extends Backbone.Model

  defaults: ->
    source: null
    target: null
    scope: 'hits'
    loadingNext: false

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
    if source = @get 'source'
      switch @get 'scope'
        when 'hits'
          @terms.reset @hits.lang source
        when 'all'
          @terms.reset()
          @_tailLoaded = false
          @next()
    else
      @terms.reset()
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

  fetch: ( lang, options = {} ) ->
    options.remove = no
    @terms
      .fetch( lang, options )
      .done ( added ) =>
        @_tailLoaded = added.length < 50
        @trigger 'update', @terms, @attributes

  hasNext: ->
    if @has( 'source' ) and @get( 'scope' ) is 'all'
      not @_tailLoaded
    else
      no

  next: ->
    if @hasNext()
      source = @get 'source'
      options = {}
      if last = @terms.last()
        options.from = last.get 'id'
      @set 'loadingNext', true
      @fetch( source, options ).always =>
        @set 'loadingNext', false
    else
      $.Deferred().resolve( [] ).promise()

