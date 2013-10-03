#= require environment
#= require collections/treegraph
#= require models/concept_node
#= require modules/helpers

class Coreon.Collections.ConceptNodes extends Coreon.Collections.Treegraph

  model: Coreon.Models.ConceptNode

  initialize: (models, options = {}) ->
    @stopListening()

    options.sourceIds = "superconcept_ids"
    options.targetIds = "subconcept_ids"
    super models, options

    if hits = options.hits
      @listenTo hits, "reset", @resetFromHits
      @resetFromHits hits
    
    @listenTo @, "add change:superconcept_ids", @addSupernodes
    @listenTo @, "reset", @addAllSupernodes
    @listenTo @, "change:label change:hit", @updateDatum

  resetFromHits: (hits) ->
    attrs = for hit in hits.models
      concept: hit.get "result"
    @reset attrs

  addSupernodes: (model) ->
    if superconceptIds = model.get "superconcept_ids"
      for superconceptId in superconceptIds
        if concept = Coreon.Models.Concept.find superconceptId
          @add concept: concept
  
  addAllSupernodes: ->
    @addSupernodes model for model in @models

  _createRoot: ->
    root = super
    repository = Coreon.application.repository()
    root.id = repository.id
    root.label = repository.get "name"
    root.root = yes
    root

  _createDatum: (model) ->
    datum = super
    datum.hit = model.has "hit"
    datum.label = model.get "label"
    datum.leaf = model.get("subconcept_ids")?.length is 0
    datum.expanded = model.get "expanded"
    datum

  updateDatum: (model) ->
    if datum = @_getDatum model
      datum.label = model.get "label"
      datum.hit = model.has "hit"

  _createTree: ->
    super
    root = @_tree.root
    edges = @_tree.edges
    for child in root.children
      edges.push
        source: root
        target: child

