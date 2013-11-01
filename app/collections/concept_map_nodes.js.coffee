#= require environment
#= require models/concept_map_node
#= require models/concept
#= require lib/tree_graph

class Coreon.Collections.ConceptMapNodes extends Backbone.Collection

  model: Coreon.Models.ConceptMapNode

  initialize: ->
    @stopListening()
    @listenTo @, 'add change:parent_node_ids', @addParentNodes
    @listenTo @, 'change:loaded', @resolveBuild
    @listenTo @, 'error', @rejectBuild

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
      @addPlaceholderNodes()
      deferred.resolveWith @, [ @models ]
      delete @build.deferred

  rejectBuild: ->
    if deferred = @build.deferred
      deferred.rejectWith @, [ @models ]
      delete @build.deferred

  isLoaded: ->
    for model in @models
      return false unless model.get 'loaded'
    true

  addParentNodes: (node) ->
    for parentNodeId in node.get 'parent_node_ids'
      @add
        model: Coreon.Models.Concept.find parentNodeId
        parent_of_hit: yes

  addPlaceholderNodes: ->
    attrs = []
    for model in @models when not model.get 'expanded'
      if isRepository = model.get('type') is 'repository'
        label = null
      else
        count = 0
        for childNodeId in model.get 'child_node_ids'
          count += 1 unless @get childNodeId
        label = "#{count}"
      if isRepository or count > 0
        attrs.push
          id: "+[#{model.id}]"
          type: 'placeholder'
          parent_node_ids: [model.id]
          label: label
    @add attrs, silent: yes

  graph: ->
    (new Coreon.Lib.TreeGraph @models).generate()
