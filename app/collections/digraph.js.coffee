#= require environment

class Coreon.Collections.Digraph extends Backbone.Collection

  initialize: (models, options = {}) ->
    @options =
      sourceIds: options.sourceIds ? "sourceIds"
      targetIds: options.targetIds ? "targetIds"
    @on "reset add remove change:#{@options.targetIds} change:#{@options.sourceIds}", @_invalidateEdges, @

  edges: ->
    @_edges ?= @_createEdges()
    @_edges[..]

  edgesIn: (target) ->
    target = @get target
    edge for edge in @edges() when edge.target is target

  edgesOut: (source) ->
    source = @get source
    edge for edge in @edges() when edge.source is source

  roots: ->
    model for model in @models when @edgesIn(model).length is 0

  leaves: ->
    model for model in @models when @edgesOut(model).length is 0

  breadthFirstOut: (callback) ->
    queue = @roots()
    queued = {}
    while queue.length > 0
      node = queue.shift()
      callback.call @, node
      for edge in @edgesOut(node.id)
        target = edge.target
        unless queued[target.id]?
          queue.push target
          queued[target.id] = true

  _createEdges: ->
    edges = []
    for model in @models
      if sourceIds = model.get @options.sourceIds
        for sourceId in sourceIds
          if source = @get sourceId
            @_createEdge edges, source, model
      if targetIds = model.get @options.targetIds
        for targetId in targetIds
          if target = @get targetId
            @_createEdge edges, model, target
    edges

  _createEdge: (edges, source, target) ->
    hasEdge = false
    for edge in edges
      if edge.source is source and edge.target is target
        hasEdge = true
        break
    unless hasEdge
      edges.push
        source: source
        target: target

  _invalidateEdges: ->
    @_edges = null
