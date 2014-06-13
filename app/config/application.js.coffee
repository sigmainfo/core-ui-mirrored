#= require environment
#= require models/session
#= require views/application_view
#= require routers/sessions_router
#= require routers/repositories_router
#= require routers/concepts_router
#= require modules/error_notifications

class Coreon.Application extends Backbone.Model

  defaults: ->
    el: '#coreon-app'
    auth_root: ''
    session: null
    selection: null
    repository: null
    scope: 'index'
    editing: false
    query: ''
    langs: []

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

  email = (session) ->
    session.get('user').email

  name = (session) ->
    session.get('user').name

  greet = (session) ->
    info = I18n.t 'notifications.account.login', name: name(session)
    Coreon.Models.Notification.info info

  watchSession: ->
    if previous = @previous('session')
      @stopListening previous
    if current = @get('session')
      @listenTo current, 'change:repository', @updateRepository
      greet(current) unless previous? and email(current) is email(previous)
    @updateRepository()

  updateRepository: ->
    if session = @get('session')
      current = session.get('repository')
      @set 'repository', current
      if previous = @previous('repository')
        @stopListening previous
      if current
        @listenTo current
                , 'remoteSettingChange'
                , @broadcastRepositoryChange
    else
      @set 'repository', null

  broadcastRepositoryChange: ->
    @trigger 'change:repositorySettings'
           , @
           , @repositorySettings()

  selectRepository: (id) ->
    @get('session').set 'current_repository_id', id

  graphUri: ->
    if repository = @repository() then repository.get("graph_uri") else null

  cacheId: ->
    if repository = @repository() then repository.get("cache_id") else null

  repository: ->
    @get("session")?.currentRepository() or null

  repositorySettings: (key = false, value) ->
    cache = if repository = @repository() then repository.localCache() else null
    if cache? and key
      if arguments.length is 1
        cache.get(key) || {}
      else
        cache.set(key, value)
        cache.save()
    else
      cache

  basicSort = (a, b) ->
    a.toLowerCase().localeCompare b.toLowerCase()

  langs: (options = {}) ->
    comparator =
      unless options.ignoreSelection
        sourceLang = @sourceLang()
        targetLang = @targetLang()
        (a, b) ->
          switch
            when a is sourceLang then -1
            when b is sourceLang then 1
            when a is targetLang then -1
            when b is targetLang then 1
            else basicSort a, b
      else basicSort

    if repository = @get('repository')
      repository.usedLanguages()
        .slice(0)
        .sort comparator
    else
      []

  sourceLang: ->
    lang = @repositorySettings()?.get('sourceLanguage') or null
    lang = null if lang is 'none'
    lang

  targetLang: ->
    lang = @repositorySettings()?.get('targetLanguage') or null
    lang = null if lang is 'none'
    lang

  lang: ->
    @sourceLang() or 'en'
