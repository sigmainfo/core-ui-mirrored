#= require environment
#= require models/concept_node
#= require modules/helpers
#= require modules/digraph

class Coreon.Collections.ConceptNodes extends Backbone.Collection

  Coreon.Modules.include @, Coreon.Modules.Digraph

  options:
    down: (node) ->
      node.get "sub_concept_ids"

  model: Coreon.Models.ConceptNode

  initialize: (models, options = {}) ->
    if options.hits?
      @hits = options.hits
      @listenTo @hits, "reset", @_onHitsReset
      @_onHitsReset()
    @initializeDigraph()
    @on "add change:childrenExpanded change:sub_concept_ids", @_onChangeChildren, @
    @on "add change:parentsExpanded change:super_concept_ids", @_onChangeParents, @
    @on "remove", @_onRemove, @

  resetFromHits: (hits) ->
    attrs = for hit in hits
      id: hit.id
      hit: hit
      childrenExpanded: true
      parentsExpanded: true
    @update attrs

  _onChangeChildren: (model) ->
    if model.get "childrenExpanded"
      @add id: childId for childId in childIds if childIds = model.get "sub_concept_ids"

  _onChangeParents: (model) ->
    if ( parentIds = model.get "super_concept_ids" ) and model.get "parentsExpanded"
      for parentId in parentIds
        if parent = @get parentId
          parent.set "childrenExpanded", true
        else
          @add id: parentId, childrenExpanded: true

  _onRemove: (model) ->
    if childIds = model.get "sub_concept_ids"
      for childId in childIds
        if model = @get childId  
          @remove model

  _onHitsReset: ->
    @resetFromHits @hits.models
