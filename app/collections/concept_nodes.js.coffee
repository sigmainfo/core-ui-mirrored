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
      continue unless @edgesIn(model).length is 0
      model
    super models, options

  focus: (models, options = {}) ->
    @remove @roots(models), except: models

  _resetFromHits: ->
    attrs = for hit in @hits.models
      _id: hit.id
      hit: hit
    @reset attrs

  _removeSubnodes: (model, collection, options) ->
    subnodes = for edge in options.previousEdges when edge.source is model
      target = edge.target
      continue unless @edgesIn(target).length is 0
      target
    @remove(subnodes, options) if subnodes.length > 0
