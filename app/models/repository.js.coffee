#= require environment
#= require models/repository_cache

class Coreon.Models.Repository extends Backbone.Model

  defaults: ->
    managers: []
    languages: []

  localCache: ->
    unless @_localCache?
      @_localCache = new Coreon.Models.RepositoryCache
      @_localCache.fetch @get('cache_id')
    @_localCache

  remoteSettings: ->
    unless @_remoteSettings? or @_remoteSettingsXHR
      graphUri = Coreon.application.graphUri().replace /\/$/, ''
      url = "#{graphUri}/repository"
      options =
        type:     'GET'
        dataType: 'json'

      @_remoteSettingsXHR = Coreon.Modules.CoreAPI.ajax url, options

      @_remoteSettingsXHR.success (data, textStatus, jqXHR) =>
        @_remoteSettings = data
        @set 'langs', data.used_languages
        @trigger 'remoteSettingChange', @

        delete @_remoteSettingsXHR

    @_remoteSettings || {}

  usedLanguages: ->
    unless @_usedLanguages
      @_usedLanguages = @remoteSettings()['used_languages']

    used = (@_usedLanguages || @get 'languages')
      .map (lang) ->
        lang.toLowerCase()
    _(used).uniq()
      

  path: ->
    "/#{@id}"
