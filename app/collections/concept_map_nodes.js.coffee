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
    repository = @at(0)
    @rootIds(yes).done (rootIds) =>
      repository.set 'child_node_ids', rootIds
      @updatePlaceholderNode repository, rootIds unless @build.deferred?
    for model in models
      @add model: model

    @resolveBuild()
    deferred.promise()

  resolveBuild: ->
    if (deferred = @build.deferred) and @isLoaded()
      @updateAllPlaceholderNodes()
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

  rootIds: (force = false) ->
    deferred = $.Deferred()
    if @_rootIds? and not force
      deferred.resolve @_rootIds
    else
      Coreon.Models.Concept.roots()
        .done (@_rootIds) =>
          deferred.resolve @_rootIds
        .fail ->
          deferred.reject()
    deferred.promise()

  addParentNodes: (node) ->
    for parentNodeId in node.get 'parent_node_ids'
      @add
        model: Coreon.Models.Concept.find parentNodeId
        parent_of_hit: yes

  updateAllPlaceholderNodes: ->
    models = (model for model in @models when model.get('type') isnt 'placeholder')
    for model in models
      @updatePlaceholderNode model, model.get('child_node_ids'), silent: yes

  updatePlaceholderNode: (model, childNodeIds, options = {}) ->
    id = "+[#{model.id}]"

    siblingNodeIds = []
    for childNodeId in childNodeIds
      siblingNodeIds.push sibling.id if sibling = @get childNodeId

    parentNodeIds = []
    parentNodeIds.push model.id

    enforce = model.get('type') is 'repository' and not @_rootIds?
    count = childNodeIds.length - siblingNodeIds.length
    label = if enforce then null else "#{count}"

    if count > 0 or enforce
      @add {
        id: id
        type: 'placeholder'
        parent_node_ids: parentNodeIds
        sibling_node_ids: siblingNodeIds
        label: label
      }, silent: yes, merge: yes
    else
      @remove id

    @trigger 'placeholder:update' unless options.silent

  graph: ->
    (new Coreon.Lib.TreeGraph @models).generate()

  expand: (id) ->
    deferred = $.Deferred()
    model = @get id

    if model.get('type') is 'repository'
      @rootIds(yes)
        .done (rootIds) =>
          @addAndLoad rootIds, deferred
    else
      @addAndLoad model.get('child_node_ids'), deferred

    deferred.promise()


  collapse: (id) ->
    deferred = $.Deferred()
    model = @get id
    @delAndUnLoad model.get('child_node_ids'), deferred
    deferred.promise()

  delAndUnLoad: (ids, deferred = $.Deferred()) ->
    nodes = []
    for id in ids
      nodes.push @get id
      @remove id
    resolve = =>
      loaded = yes
      for node in nodes
        unless node.get 'loaded'
          loaded = no
          break
      if loaded
        @stopListening @, 'change:loaded', resolve
        @updateAllPlaceholderNodes()
        deferred.resolve nodes

    @listenTo @, 'change:loaded', resolve
    resolve()

    deferred.promise()


  addAndLoad: (ids, deferred = $.Deferred()) ->
    nodes = []
    for id in ids
      @add model: Coreon.Models.Concept.find id
      nodes.push @get id

    resolve = =>
      loaded = yes
      for node in nodes
        unless node.get 'loaded'
          loaded = no
          break
      if loaded
        @stopListening @, 'change:loaded', resolve
        @updateAllPlaceholderNodes()
        deferred.resolve nodes

    @listenTo @, 'change:loaded', resolve
    resolve()

    deferred.promise()
