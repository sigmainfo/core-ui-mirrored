#= require environment

class Coreon.Lib.TreeGraph

  constructor: (@models) ->

  generate: ->
    @generateNodes()
    @setRoot()
    @generateEdges()
    @sortChildren()
    @enforceTree()
    @collectSiblings()
    tree: @root
    edges: @edges
    siblings: @siblings

  generateNodes: ->
    @nodes = {}
    @meta = {}
    #console.log 'modeeelllss'+JSON.stringify(@models)
    window.mooddeell=JSON.stringify(@models)
    for model in @models
      node = model.toJSON()
      #console.log 'node inv :'+JSON.stringify(node)
      node.children = []
      @nodes[model.id] = node
      @meta[model.id] =
        visited: false
        parents: 0

  setRoot: ->
    @root = if @models.length > 0
      @nodes[@models[0].id]
    else
      null

  generateEdges: ->
    @edges = []
    for model in @models
      target = @nodes[model.id]
      continue if target is @root
      parentNodeIds = model.get 'parent_node_ids'
      #console.log model.id+' : parentNodeIds :'+parentNodeIds 
      if parentNodeIds.length > 0
        for parentNodeId in parentNodeIds
          @connect @nodes[parentNodeId], target
          console.log 'window.tmp_nodes :'+window.tmp_nodes
          if window.tmp_nodes_dragged
            if window.tmp_nodes_dragged==target.id
               #console.log  '***'+window.tmp_nodes_dragged
               #console.log  '***'+window.tmp_nodes_selected
               @connect @nodes[window.tmp_nodes_selected], target
               #window.tmp_nodes_selected=null
               #window.tmp_nodes_dragged=null
      else
        @connect @root, target

  connect: (source, target) ->
    #console.log 'src :'+source
    #console.log 'tgt :'+target
    source.children.push target
    @meta[target.id].parents += 1
    if source.id=='551e706a73697363de190000'
       console.log 'ssss....'+JSON.stringify(source.children) 
       console.log 'ssss....'+JSON.stringify(@meta[target.id].parents) 
    @edges.push
      source: source
      target: target

  enforceTree: ->
    return unless @root?
    queue = [@root]
    while queue.length > 0
      node = queue.shift()
      node.children = for child in node.children.reverse()
        meta = @meta[child.id]
        unless meta.visited
          queue.push child
          meta.visited = yes
        if meta.parents > 1
          meta.parents -= 1
          continue
        child
      for child in node.children.reverse()
        child.parent = node

  sortChildren: ->
    for id, node of @nodes
      node.children.sort (a, b) ->
        [labelA, labelB] = [a, b].map (child) -> child.label or ""
        labelA.toLowerCase().localeCompare labelB.toLowerCase()

  collectSiblings: ->
    @siblings = []
    for id, node of @nodes
      if node.children.length > 1
        for child in (child for child in node.children)
          if child.type is 'placeholder'
            node.children.splice node.children.indexOf(child), 1
            child.sibling = node.children[node.children.length - 1]
            child.parent = node
            @siblings.push child
