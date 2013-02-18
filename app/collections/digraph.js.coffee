#= require environment

class Coreon.Collections.Digraph extends Backbone.Collection

  initialize: (models, options = {}) ->
    @options =
      sourceIds: options.sourceIds ? "sourceIds"
      targetIds: options.targetIds ? "targetIds"
    @on "reset add remove change:#{@options.targetIds} change:#{@options.sourceIds}", @_invalidateGraph, @

  edges: ->
    @_edges ?= @_createEdges()
    @_edges[..]

  edgesIn: (target) ->
    target = @get target
    edge for edge in @edges() when edge.target is target

  edgesOut: (source) ->
    source = @get source
    edge for edge in @edges() when edge.source is source

  roots: (targets) ->
    if targets
      @_rootsFor targets
    else
      model for model in @models when @edgesIn(model).length is 0

  leaves: (sources) ->
    if sources
      @_leavesFor sources
    else
      model for model in @models when @edgesOut(model).length is 0

  breadthFirstIn: (callback, options = {}) ->
    options.start ?= @roots()
    @_breadthFirst callback, options, (node) ->
      edge.target for edge in @edgesOut node

  breadthFirstOut: (callback, options = {}) ->
    options.start ?= @leaves()
    @_breadthFirst callback, options, (node) ->
      edge.source for edge in @edgesIn node

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

  _invalidateGraph: ->
    @_edges = null

  _breadthFirst: (callback, options = {}, walker) ->
    start = options.start
    delete options.start
    start = [ start ] unless Array.isArray start
    queue = (node for node in start when node = @get node)
    queued = {}
    while queue.length > 0
      node = queue.shift()
      callback.call @, node, options
      for next in walker.call @, node
        unless queued[next.id]?
          queue.push next
          queued[next.id] = true

  _rootsFor: (targets) ->
    roots = []
    @breadthFirstOut ( (model) -> roots.push model if @edgesIn(model).length is 0 ),
      start: targets
    roots

  _leavesFor: (sources) ->
    leaves = []
    @breadthFirstIn ( (model) -> leaves.push model if @edgesOut(model).length is 0 ),
      start: sources
    leaves
