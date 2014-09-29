#= require environment

class Coreon.Models.RepositorySettings extends Backbone.Model

  url: ->
    "/repository/settings"

  instance = null

  @current: ->
    instance

  @reset: ->
    instance = null

  @refresh: (force = false) ->
    deferred = $.Deferred()
    if force || !instance
      new_instance = new Coreon.Models.RepositorySettings()
      new_instance.fetch
        success: =>
          instance = new_instance
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

  @languages: ->
    instance.languages()

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

  languages: ->
    @get 'languages'



