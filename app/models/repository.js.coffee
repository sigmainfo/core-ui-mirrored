#= require environment
#= require models/repository_cache

class Coreon.Models.Repository extends Backbone.Model

  defaults: ->
    managers: []
    languages: []

  localCache: ->
    unless @cache?
      @cache = new Coreon.Models.RepositoryCache
      @cache.fetch @get('cache_id')
    @cache
    
  
  path: ->
    "/#{@id}"
