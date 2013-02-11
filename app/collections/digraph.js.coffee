#= require environment

class Coreon.Collections.Digraph extends Backbone.Collection

  edgesIn: null

  options:
    digraph:
      out: "targetIds"

  initialize: (models, options) ->
    @on "add", @_onAdd, @
    @on "remove", @_onRemove, @
    @on "change:#{@options.digraph.out}", @_onChangeTargetIds, @

  reset: (models, options = {}) ->
    super
    options.silent = true
    @_onAdd model, options for model in @models
    @

  _reset: ->
    super
    @_resetEdges()

  _resetEdges: ->
    @_tailsIn = {}
    @edgesIn = {}

  _onAdd: (model, options) ->
    if tailsIn = @_tailsIn[model.id]
      @edgesIn[model.id] = tailsIn
      delete @_tailsIn[model.id]
      model.trigger "edges:in:add", model, source for source in tailsIn
    @_updateEdges model, model.get(@options.digraph.out), null, options

  _onRemove: (model, options) ->
    if edgesIn = @edgesIn[model.id]
      @_tailsIn[model.id] = edgesIn
      delete @edgesIn[model.id]
      model.trigger "edges:in:remove", model, source for source in edgesIn
    @_updateEdges model, null, model.get(@options.digraph.out), options

  _onChangeTargetIds: (model, value, options) ->
    @_updateEdges model, value, model.previous(@options.digraph.out)

  _updateEdges: (model, targetIds = [], previousTargetIds = [], options = {}) ->
    missing = (id for id in targetIds when previousTargetIds.indexOf(id) < 0)
    deprecated = (id for id in previousTargetIds when targetIds.indexOf(id) < 0)
    @_createEdges model, missing, options
    @_deleteEdges model, deprecated, options

  _createEdges: (model, targetIds, options) ->
    @_eachEdge model, targetIds, "edges:in:add", options, (model, hash, targetId) ->
      hash[targetId] ?= []
      hash[targetId].push model

  _deleteEdges: (model, targetIds, options) ->
    @_eachEdge model, targetIds, "edges:in:remove", options, (model, hash, targetId) -> 
      if list = hash[targetId]
        position = list.indexOf model
        list.slice position, 1 if position isnt -1
        delete hash[targetId]

  _eachEdge: (model, targetIds, event, options = {}, callback) ->
    for targetId in targetIds
      target = @get targetId
      hash = if target? then @edgesIn else @_tailsIn
      callback model, hash, targetId
      target?.trigger event, target, model unless options.silent?

