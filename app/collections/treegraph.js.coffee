#= require environment
#= require collections/digraph

class Coreon.Collections.Treegraph extends Coreon.Collections.Digraph

  tree: ->
    @_createTree() unless @_tree?
    @_tree

  _createTree: ->
    @_tree = children: []
    @_parents = {}
    @breadthFirstOut @_createDatum

  _createDatum: (model) ->
    datum =
      id: model.id
      node: model
      children: []
    @_attachDatum datum
    @_fillParents datum

  _attachDatum: (datum) ->
    sources = @edgesIn[datum.id]
    parents = @_parents[datum.id]
    if sources.length is 0
      @_tree.children.push datum
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
