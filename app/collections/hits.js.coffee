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

  nodes: ->
    @_nodes ?= @_createNodes()

  edges: ->
    @_edges ?= @_createEdges()

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

  _createNode: (id, hit = null) ->
    concept: Coreon.Models.Concept.find id
    hit: hit

  _createNodes: ->
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

  _createEdges: ->
    edges = []
    nodes = @nodes()
    for id, node of nodes
      for parentId in node.concept.get "super_concept_ids"
        if nodes[parentId]?
          edges.push
            source: nodes[parentId]
            target: node
    edges

  _invalidateGraph: ->
    @_nodes = @_edges = null
