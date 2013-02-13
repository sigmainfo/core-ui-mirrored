#= require environment

class Coreon.Collections.Digraph extends Backbone.Collection

  edgesIn: null
  edgesOut: null

  options:
    digraph:
      in:  "sourceIds"
      out: "targetIds"

  initialize: (models, options = {}) ->
    options.digraph ?= {}
    options.digraph[key] = value for key, value of @options.digraph when not options.digraph[key]?
    @options = options
    super
    @on "change:#{@options.digraph.out}", @_onChangeTargetIds, @
    @on "change:#{@options.digraph.in}" , @_onChangeSourceIds, @

  _reset: ->
    super
    @_tailsIn  = {}
    @_tailsOut = {}
    @edgesIn   = {}
    @edgesOut  = {}

  add: (models = [], options) ->
    super
    for model in @_getModels models
      @_prepareEdges model
      @_connectTailsIn model, options
      @_connectTailsOut model, options
      @_evaluateTargetIds model, model.get(@options.digraph.out), options
      @_evaluateSourceIds model, model.get(@options.digraph.in), options
    @

  remove: (models, options) ->
    for model in @_getModels models
      @_removeEdge source, model, options for source in @edgesIn[model.id]
      @_removeEdge model, target, options for target in @edgesOut[model.id]
      @_dismissTargetIds model, model.get(@options.digraph.out), options
      @_dismissSourceIds model, model.get(@options.digraph.in), options
      @_swipeEdges model
    super

  _onChangeTargetIds: (model, targetIds, options) ->
    [addedIds, removedIds] = @_getChanges targetIds, model.previous(@options.digraph.out)
    @_evaluateTargetIds model, addedIds
    @_dismissTargetIds model, removedIds

  _onChangeSourceIds: (model, sourceIds, options) ->
    [addedIds, removedIds] = @_getChanges sourceIds, model.previous(@options.digraph.in)
    @_evaluateSourceIds model, addedIds
    @_dismissSourceIds model, removedIds
  
  _prepareEdges: (model) ->
    @edgesIn[model.id]  = []
    @edgesOut[model.id] = []

  _swipeEdges: (model) ->
    delete @edgesIn[model.id]
    delete @edgesOut[model.id]

  _connectTailsIn: (model, options) ->
    if @_tailsIn[model.id]?
      @_createEdge source, model, options for source in @_tailsIn[model.id]
      delete @_tailsIn[model.id]

  _connectTailsOut: (model, options) ->
    if @_tailsOut[model.id]?
      @_createEdge model, target, options for target in @_tailsOut[model.id]
      delete @_tailsOut[model.id]

  _evaluateTargetIds: (model, targetIds = [], options) ->
    for targetId in targetIds
      if @edgesIn[targetId]?
        @_createEdge model, @get(targetId), options
      else
        @_tailsIn[targetId] ?= []
        @_addToList @_tailsIn[targetId], model

  _evaluateSourceIds: (model, sourceIds = [], options) ->
    for sourceId in sourceIds
      if @edgesOut[sourceId]? 
        @_createEdge @get(sourceId), model, options
      else
        @_tailsOut[sourceId] ?= []
        @_addToList @_tailsOut[sourceId], model

  _dismissTargetIds: (model, targetIds = [], options) ->
    for targetId in targetIds
      @_removeEdge model, target, options if target = @get(targetId)
      @_removeFromList @_tailsIn[targetId], model

  _dismissSourceIds: (model, sourceIds = [], options) ->
    for sourceId in sourceIds
      @_removeEdge source, model, options if source = @get(sourceId)
      @_removeFromList @_tailsOut[sourceId], model

  _createEdge: (source, target, options) ->
    @_addToList @edgesOut[source.id], target
    @_addToList @edgesIn[target.id], source
    @_triggerEdgeEvent "add", source, target, options

  _removeEdge: (source, target, options) ->
    @_removeFromList @edgesOut[source.id], target
    @_removeFromList @edgesIn[target.id], source
    @_triggerEdgeEvent "remove", source, target, options

  _triggerEdgeEvent: (type, source, target, options = {}) -> 
    unless options.silent?
      edge =
        source: source
        target: target
      source.trigger "edge:out:#{type}", edge
      target.trigger "edge:in:#{type}", edge

  _getModels: (models = []) ->
    models = [ models ] unless _.isArray(models)
    model for model in models when model = @get model

  _addToList: (list, value) ->
    list.push value if list.indexOf(value) < 0

  _removeFromList: (list, value) ->
    if list?
      pos = list.indexOf value
      list.splice pos, 1 unless pos < 0

  _getChanges: (currentItems, previousItems = []) ->
    added   = (item for item in currentItems when previousItems.indexOf(item) < 0)
    removed = (item for item in previousItems when currentItems.indexOf(item) < 0)
    [added, removed]
