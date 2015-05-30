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
    window.mooddeell=JSON.stringify(@models)
    for model in @models
      node = model.toJSON()
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
    window.models=@models
    # console.log 'JSON modekls '+JSON.stringify(@models)
    @edges = []
    for model in @models
      target = @nodes[model.id]
      continue if target is @root
      parentNodeIds = model.get 'parent_node_ids'
      console.log 'parent ids '+parentNodeIds+ ':::: '+window.collapseList
      console.log 'parent ids2 '+(window.collapseList.indexOf(String(parentNodeIds))!=-1)
      if window.collapseList.indexOf(String(parentNodeIds))!=-1
         console.log 'in else pnode else'
      else
          console.log 'in ifff'
          if window.tmp_nodes_dragged
            if window.tmp_nodes_dragged==target.id
              @connect @nodes[window.tmp_nodes_selected], target
              window.tmp_nodes_old_parent=[]
          if parentNodeIds.length > 0
            for parentNodeId in parentNodeIds
              if window.tmp_nodes_dragged==target.id
                 if window.tmp_nodes_old_parent != undefined
                  window.tmp_nodes_old_parent.push parentNodeId
              @connect @nodes[parentNodeId], target
          else
              @connect @root, target
    window.nodes=@nodes

  connect: (source, target) ->
    #console.log 'src :'+source
    #console.log 'src1 :'+source.label
    if source==undefined
      return
    source.children.push target
    @meta[target.id].parents += 1
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
