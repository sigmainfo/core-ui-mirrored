#= require environment

class Coreon.Lib.TreeGraph

  constructor: (@models) ->

  generate: ->
    @generateNodes()
    @setRoot()
    @generateEdges()
    @enforceTree()
    tree: @root
    edges: @edges

  generateNodes: ->
    @nodes = {}
    @meta = {}
    for model in @models
      node = model.toJSON()
      node.children = []
      @nodes[model.id] = node
      @meta[model.id] =
        visited: false
        parents: 0

  setRoot: ->
    @root = if @models.length > 0
      @nodes[@models[0].id]
    else
      null

  generateEdges: ->
    @edges = []
    for model in @models
      target = @nodes[model.id]
      continue if target is @root
      parentNodeIds = model.get "parent_node_ids"
      if parentNodeIds.length is 0
        @connect @root, target
      else
        for parentNodeId in parentNodeIds
          @connect @nodes[parentNodeId], target

  connect: (source, target) ->
    source.children.push target
    @meta[target.id].parents += 1
    @edges.push
      source: source
      target: target

  enforceTree: ->
    return unless @root?
    queue = [@root]
    while queue.length > 0
      node = queue.shift()
      node.children = for child in node.children
        meta = @meta[child.id]
        unless meta.visited
          queue.push child
          meta.visited = yes
        if meta.parents > 1
          meta.parents -= 1
          continue
        child
