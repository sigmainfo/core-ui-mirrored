#= require environment
#= require collections/digraph

class Coreon.Collections.Treegraph extends Coreon.Collections.Digraph

  tree: ->
    @_createTree() unless @_tree?
    @_tree

  _createTree: ->
    @_tree =
      root:
        children: []
      edges:
        []
    @_data = {}
    @_parents = {}
    @breadthFirstOut @_processDatum

  _processDatum: (model) ->
    datum = @_getDatum model
    @_createEdges datum
    @_attachDatum datum
    @_fillParents datum

  _getDatum: (model) ->
    @_data[model.id] ?=
      id: model.id
      model: model
      children: []

  _createEdges: (datum) ->
    targets = @edgesOut[datum.id]
    for target in targets
      @_tree.edges.push
        source: datum
        target: @_getDatum target

  _attachDatum: (datum) ->
    sources = @edgesIn[datum.id]
    parents = @_parents[datum.id]
    if sources.length is 0
      @_tree.root.children.push datum
    else if sources.length is parents.length
      parents[0].children.push datum

  _fillParents: (datum) ->
    for target in @edgesOut[datum.id]
      @_parents[target.id] ?= []
      @_parents[target.id].unshift datum

  _invalidate: ->
    super
    @_tree = null
    @_parents = null
    @_data = null
