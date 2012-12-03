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
      datum.parents
    down: (datum) ->
      datum.children

  constructor: ->
    @initialize.apply @, arguments

  initialize: ( data, options = {} ) ->
    @options = @optionsWithDefaults options
    @reset data

  nodes: ->
    @_nodes

  edges: ->
    @_edges

  reset: ( data = [] ) ->
    hash = @createNodesHash data
    @_edges = @createEdges hash
    @_nodes = @createNodes hash, @_edges

  optionsWithDefaults: (options) ->
    copy = {}
    copy[key] = value for key, value of @defaults
    copy[key] = value for key, value of options
    copy

  createNodes: (hash, edges) ->
    nodes = for id, node of hash
      node.children = node.parents = null
      node
    for edge in edges
      edge.source.children ?= []
      edge.source.children.push edge.target
      edge.target.parents ?= []
      edge.target.parents.push edge.source
    nodes

  createNodesHash: (data) ->
    hash = {}
    for datum in data
      id = @options.id datum
      hash[id] ?= @options.factory id, datum
    for datum in data
      if children = @options.down datum
        for id in children
          hash[id] ?= @options.factory id
      if parents = @options.up datum
        for id in parents
          parent = @options.factory id
          hash[id] ?= parent
          if siblings = @options.down parent
            for id in siblings
              hash[id] ?= @options.factory id
    hash

  createEdges: (hash) ->
    edges = []
    for id, node of hash
      if children = @options.down node
        for id in children
          if hash[id]?
            edges.push
              source: node
              target: hash[id]
    edges
