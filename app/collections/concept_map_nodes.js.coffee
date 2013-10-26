#= require environment
#= require models/concept_map_node
#= require models/concept

class Coreon.Collections.ConceptMapNodes extends Backbone.Collection

  model: Coreon.Models.ConceptMapNode

  initialize: ->
    @stopListening()
    @listenTo @, "add change:parent_node_ids", @addParentNodes
    @listenTo @, "change:loaded", @resolveBuild
    @listenTo @, "error", @rejectBuild

  build: (models = []) ->
    @rejectBuild()
    deferred = @build.deferred = $.Deferred()

    @reset []
    @add model: Coreon.application.repository()
    @add model: model for model in models
    @resolveBuild()

    deferred.promise()

  resolveBuild: ->
    if (deferred = @build.deferred) and @isLoaded()
      deferred.resolveWith @, [ @models ]
      delete @build.deferred

  rejectBuild: ->
    if deferred = @build.deferred
      deferred.rejectWith @, [ @models ]
      delete @build.deferred

  addParentNodes: (node) ->
    for parentNodeId in node.get "parent_node_ids"
      @add model: Coreon.Models.Concept.find parentNodeId

  isLoaded: ->
    for model in @models
      return false unless model.get "loaded"
    true
