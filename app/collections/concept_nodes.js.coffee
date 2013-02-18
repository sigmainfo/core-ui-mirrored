#= require environment
#= require collections/treegraph
#= require models/concept_node
#= require modules/helpers

class Coreon.Collections.ConceptNodes extends Coreon.Collections.Treegraph

  model: Coreon.Models.ConceptNode

  initialize: (models, options = {}) ->
    options.sourceIds = "super_concept_ids"
    options.targetIds = "sub_concept_ids"
    super models, options
    if hits = options.hits
      @hits = hits
      @listenTo @hits, "reset", @_resetFromHits
      @_resetFromHits()
    @on "remove", @_removeSubnodes, @
    @on "add", @_spreadOut, @
    @on "reset", @_spreadOutAll, @
    @on "change:#{@options.targetIds}", @_spreadOutSubnodes, @ 
    @on "change:#{@options.sourceIds}", @_spreadOutSupernodes, @
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
      # continue unless @edgesIn(model).length is 0
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

  _resetFromHits: ->
    attrs = for hit in @hits.models
      _id: hit.id
      hit: hit
      expandedOut: true
      expandedIn: true
    @reset attrs

  _removeSubnodes: (model, collection, options) ->
    subnodes = for edge in options.previousEdges when edge.source is model
      target = edge.target
      continue unless @edgesIn(target).length is 0
      target
    @remove(subnodes, options) if subnodes.length > 0

  _spreadOut: (model, collection, options) ->
    @_spreadOutSubnodes model, model.get(@options.targetIds), options
    @_spreadOutSupernodes model, model.get(@options.sourceIds), options

  _spreadOutSubnodes: (model, targetIds = [], options) ->
    if model.get "expandedOut"
      previousTargetIds = model.previous(@options.targetIds) ? []
      @add { _id: id }, options for id in targetIds
      @remove id, options for id in previousTargetIds when id not in targetIds

  _spreadOutSupernodes: (model, sourceIds = [], options) ->
    if model.get "expandedIn"
      previousSourceIds = model.previous(@options.sourceIds) ? []
      for id in sourceIds
        if source = @get id
          source.set "expandedOut", true
        else
          @add { _id: id, expandedOut: true }, options
      @remove id, options for id in previousSourceIds when id not in sourceIds

  _spreadOutAll: ->
    @_spreadOut(model) for model in @models

  _toggleSubnodes: (model, expanded, options) ->
    targetIds = model.get(@options.targetIds)
    if expanded
      @_spreadOutSubnodes model, targetIds, options
    else
      @remove targetIds
