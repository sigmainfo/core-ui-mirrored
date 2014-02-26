#= require environment
#= require models/session
#= require views/application_view
#= require routers/sessions_router
#= require routers/repositories_router
#= require routers/concepts_router
#= require modules/error_notifications

class Coreon.Application extends Backbone.Model

  defaults:
    el: '#coreon-app'
    auth_root: ''
    session: null
    selection: null
    repository: null
    scope: 'index'
    editing: false

  initialize: ->
    unless Coreon.application?
      Coreon.application = @
    else
      throw new Error 'Coreon application already initialized'

    new Coreon.Views.ApplicationView model: @, el: @get('el')

    new router(@) for name, router of Coreon.Routers

  start: ->
    if authRoot = @get('auth_root')
      Coreon.Models.Session.authRoot = authRoot
    else
      throw new Error 'Authorization service root URL not given'

    @stopListening()

    @listenTo @, 'change:session', @watchSession
    @set 'session', null
    Coreon.Models.Session.load().always (session) =>
      @set 'session', session, silent: yes
      @trigger 'change:session', @, session

    @

  watchSession: ->
    if previous = @previous('session')
      @stopListening previous
    if current = @get('session')
      @listenTo current, 'change:repository', @updateRepository
    @updateRepository()

  updateRepository: ->
    current = if session = @get('session')
      session.get('repository')
    else
      null
    @set 'repository', current

  selectRepository: (id) ->
    @get('session').set 'current_repository_id', id

  graphUri: ->
    if repository = @repository() then repository.get("graph_uri") else null

  cacheId: ->
    if repository = @repository() then repository.get("cache_id") else null

  repository: ->
    @get("session")?.currentRepository() or null

  repositorySettings: (key = false, value = null) ->
    cache = if repository = @repository() then repository.localCache() else null
    if cache? and key
      if value is null
        cache.get(key) || {}
      else
        cache.set(key, value)
        cache.save()
    else
      cache

  langs: ->
    sourceLang = @sourceLang()
    targetLang = @targetLang()

    @repository().usedLanguages().slice(0)
      .sort (a, b) ->
        switch
          when a is sourceLang then -1
          when b is sourceLang then 1
          when a is targetLang then -1
          when b is targetLang then 1
          else a.localeCompare b

  sourceLang: ->
    lang = @repositorySettings()?.get('sourceLanguage') or null
    lang = null if lang is 'none'
    lang

  targetLang: ->
    lang = @repositorySettings()?.get('targetLanguage') or null
    lang = null if lang is 'none'
    lang

