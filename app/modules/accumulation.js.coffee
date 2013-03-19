#= require environment

Coreon.Modules.Accumulation =

  collection: ->
    @_collection ||= new Backbone.Collection null, model: @

  create: (attributes, options = {}) ->
    @collection().create attributes, options

  find: (id) ->
    @collection().get(id) or @fetch(id)

  fetch: (id) ->
    attrs = {}
    attrs[@::idAttribute] = id
    model = new @ attrs
    @collection().add model
    model.fetch()
    model

  upsert: (attributes) ->
    if _(attributes).isArray()
      @_upsert attrs for attrs in attributes
    else
      @_upsert attributes

  _upsert: (attributes) ->
    model = @find attributes[@::idAttribute]
    model.set attributes
