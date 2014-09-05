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

  @blueprintsFor: (type) ->
    instance.blueprintsFor type

  @propertiesFor: (type) ->
    instance.propertiesFor type

  defaults:
    blueprints: null

  sync: ( method, model, options )->
    Coreon.Modules.CoreAPI.sync method, model, options

  blueprintsFor: (type) ->
    _.findWhere @get('blueprints'), for: type

  propertiesFor: (type) ->
    @blueprintsFor(type)?['properties']



