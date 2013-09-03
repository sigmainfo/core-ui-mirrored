#= require environment

Coreon.Modules.Accumulation =

  collection: ->
    @_collection ||= new Backbone.Collection null, model: @

  create: (attributes, options = {}) ->
    options.wait ?= true
    @collection().create attributes, options

  find: (id, options = {}) ->
    if model = @collection().get id
      model.fetch() if options.fetch
      model
    else
      @fetch id

  fetch: (id) ->
    attrs = {}
    attrs[@::idAttribute] = id
    model = new @ attrs
    model.blank = true
    model.once "sync", @_fetched
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

  _fetched: (model) ->
    if model.blank
      model.blank = false
      model.trigger "nonblank"
