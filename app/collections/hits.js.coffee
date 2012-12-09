#= require environment
#= require models/hit
#= require models/concept
#= require data/digraph

class Coreon.Collections.Hits extends Backbone.Collection

  model: Coreon.Models.Hit

  initialize: ->
    @on "add", @_onAdd
    @on "remove", @_onRemove

  update: (hits = [], options = {}) ->
    removed = @_removeDropped hits, options
    added   = @_addMissing hits, options
    if removed or added
      @invalidateGraph()
      @trigger "hit:update", @, options unless options.silent?
 
  graph: ->
    @_graph ?= @createGraph()

  tree: ->
    @graph().tree()

  edges: ->
    @graph().edges()

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

  createGraph: () ->
    graph = new Coreon.Data.Digraph @models,
      factory: (id, datum) ->
        id: id
        concept: Coreon.Models.Concept.find id
        score: if datum? then datum.get "score" else null
      up: (datum) -> Coreon.Models.Concept.find(datum.id).get "super_concept_ids"
      down: (datum) -> Coreon.Models.Concept.find(datum.id).get "sub_concept_ids"
    for node in graph.nodes()
      node.concept.on "change", @updateGraph, @
    graph

  updateGraph: (options = {}) ->
    @invalidateGraph()
    @trigger "hit:graph:update", @

  invalidateGraph: ->
    if @_graph?
      for node in @_graph.nodes()
        node.concept.off null, null, @
      @_graph = null
