#= require environment
#= require models/concept_node
#= require modules/helpers
#= require modules/digraph

class Coreon.Collections.ConceptNodes extends Backbone.Collection

  Coreon.Modules.include @, Coreon.Modules.Digraph

  model: Coreon.Models.ConceptNode

  initialize: (models, options = {}) ->
    if options.hits?
      @hits = options.hits
      @listenTo @hits, "reset", @_onHitsReset
      @_onHitsReset()
    @initializeDigraph()
  
  resetFromHits: (hits) ->
    attrs = for hit in hits
      id: hit.id
      hit: hit
      childrenExpanded: true
      parentsExpanded: true
    @update attrs

  _onHitsReset: ->
    @resetFromHits @hits.models
