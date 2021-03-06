#= require environment
#= require collections/terms
#= require routers/repositories_router
#= require routers/concepts_router
#= require models/concept

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
    @concepts = new Backbone.Collection

    @updateSource()
    @updateTarget()

    @stopListening()

    @listenTo @
            , 'change:source change:scope'
            , @reset

    @listenTo Coreon.application.repositorySettings()
            , 'change:sourceLanguage'
            , @updateSource

    @listenTo Coreon.application.repositorySettings()
            , 'change:targetLanguage'
            , @updateTarget

    @listenTo Backbone.history
            , 'route'
            , @onRoute

    @listenTo @hits
            , 'reset'
            , @onHitsReset

    @listenTo @terms
            , 'reset'
            , @onTermsReset

    @listenTo @terms
            , 'add'
            , @onTermsAdd

    @listenTo @concepts
            , 'change:terms'
            , @onConceptsChange

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

  updateTarget: ->
    @set 'target', Coreon.application.targetLang()

  onRoute: ( router, route, params ) ->
    if router instanceof Coreon.Routers.RepositoriesRouter
      if route is 'show'
        @set 'scope', 'all', silent: yes
        @reset()

  onHitsReset: ->
    @set 'scope', 'hits', silent: yes
    @reset()

  onTermsReset: ->
    concepts = @terms.map ( term ) ->
      Coreon.Models.Concept.find term.get( 'concept_id' )
    @concepts.reset concepts

  onTermsAdd: ( term ) ->
    concept = Coreon.Models.Concept.find term.get( 'concept_id' )
    @concepts.add concept

  onConceptsChange: ( concept ) ->
    terms = concept.terms().lang( @get 'target' )
    @trigger 'updateTargetTerms', terms if terms.length > 0

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
      options = order: 'asc'
      if from?
        options.from = from
      else
        if last = @terms.last()
          from = options.from = last.id
      excludeFrom = @terms.get( from )?
      @set 'loadingNext', true
      @fetch( options )
        .done =>
          offset = 0
          if last = @terms.get( from )
            offset = @terms.indexOf( last )
          offset += 1 if excludeFrom
          tail = @terms.models[offset..]
          @_tailLoaded = yes if tail.length < 40
          @trigger 'append', tail
        .always =>
          @set 'loadingNext', false
    else
      nullPromise()

  prev: ( from ) ->
    if @hasPrev()
      options = order: 'desc'
      if from?
        options.from = from
      else
        if first = @terms.first()
          from = options.from = first.id
      excludeFrom = @terms.get( from )?
      @set 'loadingPrev', true
      @fetch( options )
        .done =>
          offset = @terms.models.length
          if first = @terms.get( from )
            offset = @terms.indexOf( first )
            offset -= 1 if excludeFrom
          head = if offset < 0 then [] else @terms.models[..offset]
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
