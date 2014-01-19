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
    loadingPrev: false

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

  fetch: ( options = {} ) ->
    lang = @get 'source'
    options.remove = no
    @terms.fetch lang, options

  hasWideScope: ->
    @has( 'source' ) and @get( 'scope' ) is 'all'

  hasNext: ->
    if @hasWideScope()
      not @_tailLoaded
    else
      no

  hasPrev: ->
    if @hasWideScope()
      not @_headLoaded
    else
      no

  nullPromise = ->
    $.Deferred().resolve( [] ).promise()

  next: ( from ) ->
    if @hasNext()
      excludeFrom = @terms.get( from )?
      options = order: 'asc'
      if from?
        options.from = from
      else
        if last = @terms.last()
          from = options.from = last.id
      @set 'loadingNext', true
      @fetch( options )
        .done =>
          last   = @terms.get from
          offset = @terms.indexOf last
          offset += 1 if excludeFrom
          tail   = @terms.tail offset
          @_tailLoaded = yes if tail.length < 40
          @trigger 'append', tail
        .always =>
          @set 'loadingNext', false
    else
      nullPromise()

  prev: ( from ) ->
    if @hasPrev()
      excludeFrom = @terms.get( from )?
      options = order: 'desc'
      if from?
        options.from = from
      else
        if first = @terms.first()
          from = options.from = first.id
      @set 'loadingPrev', true
      @fetch( options )
        .done =>
          first  = @terms.get from
          offset = @terms.indexOf first
          offset += 1 unless excludeFrom
          offset = 0 if offset < 0
          head   = @terms.head offset
          @_headLoaded = yes if head.length < 40
          @trigger 'prepend', head
        .always =>
          @set 'loadingPrev', false
    else
      nullPromise()

  clearTerms: ( options = {} ) ->
    @terms.reset()
    @_tailLoaded = no
    @_headLoaded = no
    @trigger 'reset', @terms, @attributes unless options.silent
