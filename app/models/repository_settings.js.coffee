#= require environment

class Coreon.Models.RepositorySettings extends Backbone.Model

  getSettings: ->
    deferred = $.Deferred()

    if @_settings? && @_id == Coreon.application.repository().get('id')
      deferred.resolve @_settings
    else
      @_settings = null
      @_id = Coreon.application.repository().get('id')
      graphUri = Coreon.application.graphUri().replace /\/$/, ''
      url = "#{graphUri}/repository/settings"
      options =
        type:     'GET'
        dataType: 'json'

      request = Coreon.Modules.CoreAPI.ajax url, options

      request.success (data, textStatus, jqXHR) =>
        @_settings = data
        deferred.resolve @_settings

    deferred.promise()

  blueprints_for: (type, fo) ->
    deferred = $.Deferred()
    @getSettings().done (settings) ->
      deferred.resolve _.findWhere settings['blueprints'], { for: type }
    deferred.promise()

  properties_for: (type) ->
    deferred = $.Deferred()
    @blueprints_for(type).done (blueprints) ->
      deferred.resolve blueprints['properties']
    deferred.promise()

