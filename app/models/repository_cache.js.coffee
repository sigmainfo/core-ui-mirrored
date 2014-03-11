#= require environment

class Coreon.Models.RepositoryCache extends Backbone.Model

  defaults: ->
    sourceLang: null
    targetLang: null

  url: ->
    false

  initialize: (attrs, options = {}) ->
    @app = options.app or Coreon.application

    @on 'change:sourceLang change:targetLang'
       , @updateLangs
       , @
    @updateLangs()

  updateLangs: ->
    langs = []
    langs.push sourceLang if sourceLang = @get('sourceLang')
    langs.push targetLang if targetLang = @get('targetLang')
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
