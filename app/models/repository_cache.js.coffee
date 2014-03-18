#= require environment

class Coreon.Models.RepositoryCache extends Backbone.Model

  defaults: ->
    sourceLanguage: null
    targetLanguage: null

  url: ->
    false

  initialize: (attrs, options = {}) ->
    @app = options.app or Coreon.application

    @off null, null, @
    @on 'change:sourceLanguage change:targetLanguage'
       , @updateLangs
       , @
    @updateLangs()

  updateLangs: ->
    langs = []
    langs.push sourceLang if sourceLang = @get('sourceLanguage')
    langs.push targetLang if targetLang = @get('targetLanguage')
    @app.set 'langs', langs

  sync: (method, model, options) ->
    switch method
      when 'read'
        rawCache = localStorage.getItem options
        jsonCache = JSON.parse rawCache
        model.set jsonCache
        model.id = options
      when 'delete'
        localStorage.removeItem model.id unless model.isNew()
      when 'create', 'update', 'patch'
        localStorage.setItem model.id, JSON.stringify model.toJSON()
