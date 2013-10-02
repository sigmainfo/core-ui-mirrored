#= require environment
#= require collections/treegraph
#= require models/concept_node
#= require modules/helpers

class Coreon.Collections.ConceptNodes extends Coreon.Collections.Treegraph

  model: Coreon.Models.ConceptNode

  initialize: (models, options = {}) ->
    options.sourceIds = "superconcept_ids"
    options.targetIds = "subconcept_ids"
    super models, options
    if hits = options.hits
      @hits = hits
      @listenTo @hits, "reset", @_resetFromHits
      @_resetFromHits()
    @on "change", @update, @
    @on "remove", @_removeSubnodes, @
    @on "add", @_spreadOut, @
    @on "reset", @_spreadOutAll, @
    @on "change:#{@options.targetIds}", @_spreadOutSubnodes, @ 
    @on "reset add", @_expandAll, @
    @on "change:#{@options.targetIds}", @_expandSubnodes, @ 
    @on "change:expandedOut", @_toggleSubnodes, @

  remove: (models, options = {}) ->
    options.previousEdges = @edges()
    models = [ models ] unless Array.isArray models
    models = for model in models when model = @get model
      if except = options.except
        except = [ except ] unless Array.isArray except
        filter = false
        for exception in except when exception = @get exception
          if model is exception
            filter = true
            break
        continue if filter
      edgesIn = @edgesIn model
      if edgesIn.length > 0
        keep = false
        for edge in edgesIn
          if edge.source.get "expandedOut"
            keep = true
            break
        continue if keep
      model
    super models, options

  focus: (models, options = {}) ->
    @remove @roots(models), except: models

  update: (model) ->
    @_updateDatum @_getDatum(model), model if @_tree

  _createRoot: ->
    root = super
    repository = Coreon.application.repository()
    root.id = repository.id
    root.label = repository.get "name"
    root.root = yes
    root

  _createDatum: (model) ->
    @_updateDatum super, model

  _updateDatum: (datum, model) ->
    datum.hit = model.has("hit")
    datum.label = model.get "label"
    datum.leaf = model.get("subconcept_ids")?.length is 0
    datum.expandedOut = model.has("expandedOut") and model.get("expandedOut")
    datum

  _resetFromHits: ->
    model.set "hit", null for model in @models
    attrs = for hit in @hits.models
      concept = hit.get "result"
      id: concept.id
      concept: concept
      hit: hit
      expandedOut: true
    @reset attrs

  _removeSubnodes: (model, collection, options) ->
    subnodes = for edge in options.previousEdges when edge.source is model
      target = edge.target
      continue unless @edgesIn(target).length is 0
      target
    @remove(subnodes, options) if subnodes.length > 0

  _spreadOut: (model, collection, options) ->
    @_spreadOutSubnodes model, model.get(@options.targetIds), options

  _spreadOutSubnodes: (model, targetIds = [], options) ->
    if model.get "expandedOut"
      previousTargetIds = model.previous(@options.targetIds) ? []
      @add { id: id }, options for id in targetIds
      @remove id, options for id in previousTargetIds when id not in targetIds

  _spreadOutAll: (collection, options)->
    @_spreadOut(model, options) for model in @models

  _toggleSubnodes: (model, expanded, options) ->
    targetIds = model.get @options.targetIds
    if expanded
      @_spreadOutSubnodes model, targetIds, options
    else
      @remove targetIds

  _expandAll: (collection, options) ->
    for model in @models
      @_expandSubnodes model, model.get(@options.targetIds), options

  _expandSubnodes: (model, targetIds = [], options) ->
    if targetIds.length > 0 and targetIds.length is @edgesOut(model).length
      model.set "expandedOut", true 
