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

    @loadingHits = no
    if hits = options.hits
      @listenTo hits, "reset", @resetFromHits
      @resetFromHits hits
    
    @listenTo @, "add change:superconcept_ids", @addSupernodes
    @listenTo @, "change:label change:hit", @updateDatum
    @listenTo @, "change:loaded", @updateLoadedState

  resetFromHits: (hits) ->
    attrs = for hit in hits.models
      concept: hit.get "result"
      hit: hit
    @reset attrs
    @addSupernodes model for model in @models
    @loadingHits = not @isCompletelyLoaded()

  addSupernodes: (model) ->
    if superconceptIds = model.get "superconcept_ids"
      for superconceptId in superconceptIds
        if concept = Coreon.Models.Concept.find superconceptId
          attrs = concept: concept
          if model.has("hit") or model.get("parent_of_hit")
            attrs.parent_of_hit = yes
          @add attrs, merge: yes

  _createRoot: ->
    root = super
    root.type = "repository"
    repository = Coreon.application.repository()
    root.id = repository.id
    root.label = repository.get "name"
    root

  _createDatum: (model) ->
    datum = super
    datum.type = "concept"
    datum.hit = model.has "hit"
    datum.label = model.get "label"
    datum.leaf = model.get("subconcept_ids")?.length is 0
    datum.expanded = model.get "expanded"
    datum.parent_of_hit = model.get "parent_of_hit"
    datum

  _createPlaceholder: (model) ->
    type: "placeholder"
    children: []
    id: "+#{model.id}"

  updateDatum: (model) ->
    if datum = @_getDatum model
      datum.label = model.get "label"
      datum.hit = model.has "hit"

  _createTree: ->
    if @loadingHits
      repository = @_createRoot()
      placeholder = @_createPlaceholder repository
      repository.children.push placeholder
      @_tree =
        root: repository
        edges: [
          source: repository
          target: placeholder
        ]
    else
      super
      root = @_tree.root
      edges = @_tree.edges
      for child in root.children
        edges.push
          source: root
          target: child

  isCompletelyLoaded: ->
    return false for model in @models when not model.get("loaded")
    true

  updateLoadedState: ->
    if @isCompletelyLoaded()
      @loadingHits = no
      @_invalidateGraph()
      @trigger "loaded"
