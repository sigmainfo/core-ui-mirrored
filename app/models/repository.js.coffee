#= require environment
#= require models/repository_cache

class Coreon.Models.Repository extends Backbone.Model

  idAttribute: "id"

  defaults: ->
    managers: []
    languages: []

  localCache: ->
    unless @cache?
      @cache = new Coreon.Models.RepositoryCache
      @cache.fetch @get('cache_id')
    @cache
    
  