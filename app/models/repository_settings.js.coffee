#= require environment

class Coreon.Models.RepositorySettings extends Backbone.Model

  url: ->
    "/repository/settings"

  instance = null

  @current: (force = false) ->
    instance = if (force || !instance) then new Coreon.Models.RepositorySettings() else instance

  @resetCurrent: ->
    instance = null

  defaults:
    blueprints: null

  sync: ( method, model, options )->
    Coreon.Modules.CoreAPI.sync method, model, options

  blueprints_for: (type) ->
    deferred = $.Deferred()
    if @get('blueprints')?
      deferred.resolve _.findWhere @get('blueprints'), { for: type }
    else
      @fetch
        success: =>
          deferred.resolve _.findWhere @get('blueprints'), { for: type }
    deferred.promise()


  properties_for: (type) ->
    deferred = $.Deferred()
    @blueprints_for(type).done (blueprints) ->
      deferred.resolve blueprints['properties']
    deferred.promise()



