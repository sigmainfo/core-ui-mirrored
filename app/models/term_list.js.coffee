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
            , @reset

    @listenTo Coreon.application.repositorySettings()
            , 'change:sourceLanguage'
            , @updateSource

    @listenTo Backbone.history
            , 'route'
            , @onRoute

    @listenTo @hits
            , 'reset'
            , @onHitsReset

  reset: ->
    if source = @get 'source'
      switch @get 'scope'
        when 'hits'
          @terms.reset @hits.lang source
        when 'all'
          @clearTerms silent: yes
          @next()
    else
      @terms.reset()
    @trigger 'reset', @terms, @attributes

  updateSource: ->
    @set 'source', Coreon.application.sourceLang()

  onRoute: ( router, route, params ) ->
    if router instanceof Coreon.Routers.RepositoriesRouter
      if route is 'show'
        @set 'scope', 'all', silent: yes
        @reset()

  onHitsReset: ->
    @set 'scope', 'hits', silent: yes
    @reset()

  fetch: ( lang, options = {} ) ->
    options.remove = no
    @terms
      .fetch( lang, options )
      .done ( added ) =>
        @_tailLoaded = added.length < 50

  hasNext: ->
    if @has( 'source' ) and @get( 'scope' ) is 'all'
      not @_tailLoaded
    else
      no

  next: ( from ) ->
    if @hasNext()
      source = @get 'source'
      options = {}
      if from?
        options.from = from
      else if last = @terms.last()
        options.from = last.id
      @set 'loadingNext', true
      @fetch( source, options )
        .done ( terms ) =>
          @trigger 'append', terms
        .always =>
          @set 'loadingNext', false
    else
      $.Deferred().resolve( [] ).promise()

  clearTerms: ( options = {} ) ->
    @terms.reset()
    @_tailLoaded = false
    @trigger 'reset', @terms, @attributes unless options.silent
