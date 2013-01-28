#= require environment
#= require modules/helpers

Coreon.Modules.Digraph =

  initializeDigraph: ->
    @options ?= {}
    @options.down ?= (model) -> model.get "childIds"

  tree: ->
    data = @_createData @models
    rels = @_createRelations data
    @_createTree data, rels
      
  _createData: (models) ->
    data = {}
    for model in models
      data[model.id] ?= @_datum model
    data

  _datum: (model) ->
    id: model.id
    model: model
    children: []

  _createRelations: (data) ->
    rels = {}
    for id, datum of data
      down = @_down datum.model
      rels[id] ?= up: []
      rels[id].down = down
      for downId in down
        rels[downId] ?= up: []
        rels[downId].up.push id
    rels

  _down: (model) ->
    if ids = @options.down model
      id for id in ids when @get id
    else
      []

  _createTree: (data, rels) ->
    children = (datum for id, datum of data when rels[id].up.length is 0)
    @_composeTree children, data, rels 
    id: "root"
    children: children

  _composeTree: (current, data, rels) ->
    next = []
    for datum in current
      downIds = rels[datum.id].down
      for downId in downIds 
        downRels = rels[downId]
        downDatum = data[downId]
        up = downRels.up
        if up.length > 1
          up.splice up.indexOf(datum.id), 1
        else if up.length is 1
          datum.children.push downDatum
          next.push downDatum 
    @_composeTree next, data, rels unless next.length is 0
