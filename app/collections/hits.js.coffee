#= require environment
#= require models/hit
#= require models/concept

class Coreon.Collections.Hits extends Backbone.Collection

  model: Coreon.Models.Hit

  initialize: ->
    @on "add", @_onAdd
    @on "remove", @_onRemove

  update: (hits = [], options = {}) ->
    updated = @_removeDropped hits, options
    updated ||= @_addMissing hits, options
    if updated
      @_invalidateGraph()
      @trigger "hit:update", @, options unless options.silent?

  graph: ->
    @_graph ?= @_createGraph()

  nodes: ->
    @graph().nodes

  edges: ->
    @graph().edges

  roots: ->
    @graph().roots

  _removeDropped: (hits, options) ->
    drops = []
    for model in @models
      keep = false
      for hit in hits
        if hit.id is model.id
          keep = true
          break
      drops.push model unless keep
    for drop in drops
      @remove drop, options
    drops.length > 0

  _addMissing: (hits, options) ->
    updated = false
    for hit in hits
      unless @get(hit.id)?
        @add [hit], options
        updated = true
    updated

  _onAdd: (model, collection, options) ->
    @_triggerEventOnConcept "add", model, collection, options

  _onRemove: (model, collection, options) ->
    @_triggerEventOnConcept "remove", model, collection, options

  _triggerEventOnConcept: (event, model, collection, options) ->
    concept = Coreon.Models.Concept.find model.id
    concept.trigger "hit:#{event}", model, collection, options

  _createGraph: ->
    nodesHash = @_createNodesHash()
    edges = @_createEdges nodesHash
    @_createRelations edges
    nodes = []
    roots = []
    for id, node of nodesHash
      nodes.push node
      roots.push node if node.parents is null
    edges: edges
    nodes: nodes
    roots: roots

  _createNodesHash: ->
    nodes = {}
    for hit in @models
      nodes[hit.id] = @_createNode hit.id, hit
      for parentId in nodes[hit.id].concept.get "super_concept_ids"
        nodes[parentId] ||= @_createNode parentId
        for siblingId in nodes[parentId].concept.get "sub_concept_ids"
          nodes[siblingId] ||= @_createNode siblingId
      for childId in nodes[hit.id].concept.get "sub_concept_ids"
        nodes[childId] ||= @_createNode childId
    nodes

  _createNode: (id, hit = null) ->
    id: id
    concept: Coreon.Models.Concept.find id
    hit: hit
    parents: null
    children: null

  _createEdges: (nodes) ->
    edges = []
    for id, node of nodes
      for parentId in node.concept.get "super_concept_ids"
        if nodes[parentId]?
          edges.push
            source: nodes[parentId]
            target: node
    edges

  _createRelations: (edges) ->
    for edge in edges
      edge.source.children ?= []
      edge.source.children.push edge.target
      edge.target.parents ?= []
      edge.target.parents.push edge.source

  _invalidateGraph: ->
    @_graph = null
