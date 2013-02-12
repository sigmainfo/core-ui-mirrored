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
    models = if _.isArray(models) then models[..] else [ models ]
    for model in models when model = @get model
      @edgesIn[model.id]  = []
      @edgesOut[model.id] = []
      if @_tailsIn[model.id]?
        for source in @_tailsIn[model.id]
          @edgesIn[model.id].push source  if @edgesIn[model.id].indexOf(source)  < 0
          @edgesOut[source.id].push model if @edgesOut[source.id].indexOf(model) < 0
        delete @_tailsIn[model.id]
      if tailsOut = @_tailsOut[model.id]
        for source in tailsOut
          @edgesIn[source.id].push model  if @edgesIn[source.id].indexOf(model)  < 0
          @edgesOut[model.id].push source if @edgesOut[model.id].indexOf(source) < 0
        delete @_tailsOut[model.id]
      if targetIds = model.get @options.digraph.out
        for targetId in targetIds
          if @edgesIn[targetId]?
            target = @get targetId
            @edgesIn[target.id].push model  if @edgesIn[target.id].indexOf(model)  < 0
            @edgesOut[model.id].push target if @edgesOut[model.id].indexOf(target) < 0
          else
            @_tailsIn[targetId] ?= []
            @_tailsIn[targetId].push model if @_tailsIn[targetId].indexOf(model) < 0
      if sourceIds = model.get @options.digraph.in
        for sourceId in sourceIds
          if @edgesOut[sourceId]? 
            source = @get sourceId
            @edgesIn[model.id].push source  if @edgesIn[model.id].indexOf(source)  < 0
            @edgesOut[source.id].push model if @edgesOut[source.id].indexOf(model) < 0
          else
            @_tailsOut[sourceId] ?= []
            @_tailsOut[sourceId].push model if @_tailsOut[sourceId].indexOf(model) < 0
    @

  remove: (models = [], options) ->
    models = if _.isArray(models) then models[..] else [ models ]
    for model in models when model = @get model
      for target in @edgesOut[model.id]
        pos = @edgesIn[target.id].indexOf(model)
        @edgesIn[target.id].splice pos, 1
      delete @edgesOut[model.id] 
      for source in @edgesIn[model.id]
        pos = @edgesOut[source.id].indexOf(model)
        @edgesOut[source.id].splice pos, 1
      delete @edgesIn[model.id]
      if targetIds = model.get @options.digraph.out
        for targetId in targetIds
          if tailsIn = @_tailsIn[targetId]
            pos = tailsIn.indexOf(model)
            @_tailsIn[targetId].splice pos, 1
      if sourceIds = model.get @options.digraph.in
        for sourceId in sourceIds
          if tailsOut = @_tailsOut[sourceId]
            pos = tailsOut.indexOf(model)
            @_tailsOut[sourceId].splice pos, 1
    super

  _onChangeTargetIds: (model, targetIds, options) ->
    previousTargetIds = model.previous(@options.digraph.out) ? []
    addedIds =   (id for id in targetIds when previousTargetIds.indexOf(id) < 0)
    removedIds = (id for id in previousTargetIds when targetIds.indexOf(id) < 0)
    for targetId in addedIds
      if @edgesIn[targetId]?
        target = @get targetId
        @edgesIn[target.id].push model  if @edgesIn[target.id].indexOf(model)  < 0
        @edgesOut[model.id].push target if @edgesOut[model.id].indexOf(target) < 0
      else
        @_tailsIn[targetId] ?= []
        @_tailsIn[targetId].push model if @_tailsIn[targetId].indexOf(model) < 0
    for targetId in removedIds
      if @edgesIn[targetId]?
        pos = @edgesIn[targetId].indexOf(model)
        @edgesIn[targetId].splice pos, 1
      if @_tailsIn[targetId]?
        pos = @_tailsIn[targetId].indexOf(model)
        @_tailsIn[targetId].splice pos, 1
      if @edgesOut[model.id]?
        target = @get targetId
        pos = @edgesOut[model.id].indexOf(target)
        @edgesOut[model.id].splice pos, 1

  _onChangeSourceIds: (model, sourceIds, options) ->
    previousSourceIds = model.previous(@options.digraph.in) ? []
    addedIds =   (id for id in sourceIds when previousSourceIds.indexOf(id) < 0)
    removedIds = (id for id in previousSourceIds when sourceIds.indexOf(id) < 0)
    for sourceId in addedIds
      if @edgesIn[sourceId]?
        source = @get sourceId
        @edgesIn[model.id].push source if @edgesIn[model.id].indexOf(source) < 0
        @edgesOut[sourceId].push model if @edgesOut[sourceId].indexOf(model) < 0
      else
        @_tailsOut[sourceId] ?= []
        @_tailsOut[sourceId].push model if @_tailsOut[sourceId].indexOf(model) < 0
    for sourceId in removedIds
      if @edgesIn[model.id]?
        source = @get sourceId
        pos = @edgesIn[model.id].indexOf source
        @edgesIn[model.id].splice pos, 1
      if @_tailsOut[sourceId]?
        pos = @_tailsOut[sourceId].indexOf model
        @_tailsOut[sourceId].splice pos, 1
      if @edgesOut[sourceId]?
        pos = @edgesOut[sourceId].indexOf model
        @edgesOut[sourceId].splice pos, 1
