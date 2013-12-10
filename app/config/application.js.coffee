#= require environment
#= require models/session
#= require views/application_view
#= require routers/sessions_router
#= require routers/repositories_router
#= require routers/concepts_router
#= require modules/error_notifications

class Coreon.Application extends Backbone.Model

  defaults:
    el: "#coreon-app"
    editMode: false

  initialize: ->
    unless Coreon.application?
      Coreon.application = @
    else
      throw new Error "Coreon application already initialized"
    Coreon.Models.Session.auth_root = @get "auth_root"
    view = new Coreon.Views.ApplicationView model: @, el: @get "el"
    new router view for name, router of Coreon.Routers

  start: ->
    unless @has "auth_root"
      throw new Error "Authorization service root URL not given"
    Coreon.Models.Session.load().always (session) =>
      @set "session", session
    @

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
    if settings = @repositorySettings()
      settings.get 'sourceLanguage'
    else
      null

  targetLang: ->
    if settings = @repositorySettings()
      settings.get 'targetLanguage'
    else
      null
