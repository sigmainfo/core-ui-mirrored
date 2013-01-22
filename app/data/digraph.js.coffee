#= require environment

class Coreon.Data.Digraph
  
  defaults:
    id: (datum) ->
      datum.id
    factory: (id, datum) ->
      copy = {}
      copy[key] = value for key, value of datum
      copy
    up: (datum) ->
      datum.parent_ids
    down: (datum) ->
      datum.child_ids
      
  constructor: ->
    @initialize.apply @, arguments

  initialize: ( data, options = {} ) ->
    @options = @optionsWithDefaults options
    @reset data

  optionsWithDefaults: (options) ->
    copy = {}
    copy[key] = value for key, value of @defaults
    copy[key] = value for key, value of options
    copy

  reset: ( data = [] ) ->
    @hash = {}
    @createNodes data
    @update()

  add: ( data = []) ->
    @createNodes data
    @update()

  remove: (ids... ) ->
    for id in ids
      delete @hash[id]
    @update()

  update: ->
    @updateEdges()
    @updateNodes()
    @updateSelections()

  createNodes: (data) ->
    for datum in data
      id = @options.id datum
      @hash[id] ?= @options.factory id, datum
    @hash

  updateEdges: ->
    edges_hash = {}
    for node_id, node of @hash
      if child_ids = @options.down node
        for child_id in child_ids
          if @hash[child_id]
            edges_hash["#{node_id}-[:BROADER]->#{child_id}"] ?=
              source: node
              target: @hash[child_id]
      if parent_ids = @options.up node
        for parent_id in parent_ids
          if @hash[parent_id]
            edges_hash["#{parent_id}-[:BROADER]->#{node_id}"] ?=
              source: @hash[parent_id]
              target: node
    @edges = (edge for key, edge of edges_hash)

  updateNodes: ->
    @nodes = for id, node of @hash
      node.children = node.parents = null
      node
    for edge in @edges
      edge.source.children ?= []
      edge.source.children.push edge.target
      edge.target.parents ?= []
      edge.target.parents.push edge.source
    @nodes

  updateSelections: ->
    @roots = []
    @leaves = []
    @multiParentNodes = []

    for node in @nodes
      if node.parents?.length > 0
        if node.parents.length > 1
          @multiParentNodes.push node 
      else
        @roots.push node
      @leaves.push node unless node.children?.length > 0

  tree: ->
    root =
      treeUp: []
      treeDown: @roots
    for node in @nodes
      node.treeUp   = if node.parents?  then node.parents[..]  else [] 
      node.treeDown = if node.children? then node.children[..] else []
    @down (node) ->
      node.treeUp.push(root) if node.treeUp.length is 0
      removed = []
      for child in node.treeDown
        if child.treeUp.length > 1
          child.treeUp = ( up for up in child.treeUp when up isnt node )
          removed.push child
      node.treeDown = ( down for down in node.treeDown when removed.indexOf(down) < 0 )
    root

  down: (nodes..., callback) ->
    nodes = @roots if nodes.length is 0
    children = []
    try
      for node in nodes
        callback node
        node._visited = true
      for node in nodes
        if node.children?.length > 0
          for child in node.children
            children.push child if child._visited isnt true
            child._visited = true
      if children.length > 0
        @down children..., callback
      else
        @cleanUpAfterWalk()
    catch error
      @cleanUpAfterWalk()

  cleanUpAfterWalk: ->
    delete node._visited for node in @nodes
