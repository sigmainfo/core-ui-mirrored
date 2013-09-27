#= require environment
#= require collections/digraph

class Coreon.Collections.Treegraph extends Coreon.Collections.Digraph

  initialize: ->
    super
    @on "change", @_updateDatum, @

  tree: ->
    @_createTree() unless @_tree?
    @_tree

  _createTree: ->
    repository = Coreon.application.repository()
    @_data = {}
    @_parents = {}
    @_tree =
      root:
        id: repository.id
        label: repository.get("name")
        root: yes
        children: []
      edges:
        []
    @breadthFirstIn @_processDatum

  _processDatum: (model) ->
    datum = @_getDatum model
    @_createDatumEdges datum
    @_attachDatum datum
    @_fillParents datum

  _getDatum: (model) ->
    key = model.id or model.cid
    @_data[key] ?=
      id: model.id
      label: model.get "label"
      hit: model.has("hit")
      children: []
      leaf: model.get("subconcept_ids")?.length is 0
      expandedIn: model.has("expandedIn") and model.get("expandedIn")
      expandedOut: model.has("expandedOut") and model.get("expandedOut")

  _createDatumEdges: (datum) ->
    targets = ( edge.target for edge in @edgesOut datum.id )
    for target in targets
      @_tree.edges.push
        source: datum
        target: @_getDatum target

  _attachDatum: (datum) ->
    sources = ( edge.source for edge in @edgesIn datum.id )
    parents = @_parents[datum.id]
    if sources.length is 0
      @_tree.root.children.push datum
    else if sources.length is parents.length
      parents[0].children.push datum

  _fillParents: (datum) ->
    for edge in @edgesOut datum.id
      target = edge.target
      @_parents[target.id] ?= []
      @_parents[target.id].unshift datum

  _invalidateGraph: ->
    super
    @_tree    = null
    @_parents = null
    @_data    = null

  _updateDatum: (model, options) ->
    key = model.id or model.cid
    if datum = @_data?[key]
      datum.label = model.get "label"
      datum.hit = model.has "hit"
      datum.leaf = model.get("subconcept_ids").length is 0
