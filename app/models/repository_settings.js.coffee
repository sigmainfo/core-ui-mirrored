#= require environment

class Coreon.Models.RepositorySettings extends Backbone.Model

  url: ->
    "/repository/settings"

  instance = null

  @reset: ->
    instance = null

  @refresh: (force = false) ->
    deferred = $.Deferred()
    if force || !instance
      instance = new Coreon.Models.RepositorySettings()
      instance.fetch
        success: =>
          deferred.resolve instance
    else
      deferred.resolve instance
    deferred.promise()

  @blueprintsFor: (entity) ->
    instance.blueprintsFor entity

  @propertiesFor: (entity) ->
    instance.propertiesFor entity

  @propertyFor: (entity, key) ->
    instance.propertyFor entity, key

  defaults:
    blueprints: null

  sync: ( method, model, options )->
    Coreon.Modules.CoreAPI.sync method, model, options

  blueprintsFor: (entity) ->
    _.findWhere @get('blueprints'), for: entity

  propertiesFor: (entity) ->
    @blueprintsFor(entity)?['properties']

  propertyFor: (entity, key) ->
    _.findWhere @propertiesFor(entity), key: key



