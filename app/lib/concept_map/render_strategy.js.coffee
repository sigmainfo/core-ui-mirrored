#= require environment
#= require d3
#= require helpers/repository_path

class Coreon.Lib.ConceptMap.RenderStrategy

  constructor: (@parent) ->
    @layout = d3.layout.tree()
    @diagonal = d3.svg.diagonal()
    @dragListener = d3.behavior.drag()
    @dragStarted = null
    @selectedNode=null
    @draggingNode=null

  resize: (@width, @height) ->

  initiateDrag: (d, domNode) ->
    @draggingNode=d
    console.log '@draggingNode:'+@draggingNode.id
    svgGroup=d3.select('g.concept-map')
    that=@
    svgGroup.selectAll("g.concept-node").sort (a, b)->
      console.log '@draggingNode:'+that.draggingNode.id
      if a.id != that.draggingNode.id 
        1
      else 
        -1
    #window.treee.nodes(d)    
    #console.log 'mmm'+that.layout.nodes(d)    
    #console.log 'mmm'+@layout.nodes(@draggingNode)    
    #console.log 'nnn'+d.label    
    #console.log 'ooo'+@draggingNode.label    
    
    @dragStarted = null    
  
  
  render: (graph) ->
    deferred = $.Deferred()    
    nodes    = @renderNodes graph.tree
    siblings = @renderSiblings graph.siblings
    edges    = @renderEdges graph.edges

    all = @parent.selectAll('.concept-node, .sibling-node')
      .data(nodes.data().concat(siblings.data()), (datum) -> datum.id )
    _.defer @updateLayout, all, edges, deferred
    that = this
    @dragListener.on 'dragstart', (d) ->
      console.log 'drag start'
      that.dragStarted= true;
      #window.nodes1=window.treee.nodes(d)
      d3.event.sourceEvent.stopPropagation()
      
      
        
    @dragListener.on 'drag', (d) ->
      if d.type=='repository'
        console.log 'repo not supported....'
        return
      if that.dragStarted
        domNode = this;
        that.initiateDrag(d, domNode);  
      cords1=d3.mouse(this)
      node=d3.select(this)
      
      d.x += d3.event.dx;
      d.y += d3.event.dy;
      node.style('z-index',-100)
      node.attr("transform", "translate(" + d.x + "," + d.y+ ")");      
      #console.log 'd label'+d.label
      #console.log 'd type'+d.type
      #console.log 'd path'+d.path
      #console.log 'd id'+d.id
      #console.log 'd parent'+d.parent.label
      #console.log 'd children'+d.children.length      
      #console.log 'd children'+JSON.stringify(Coreon.Models.Concept.find(d.id))
      #@con=Coreon.Models.Concept.find(d.id)
      #data =
      #  superconcept_ids: []
      #  subconcept_ids: ['551e6f4973697363de050000','551e6f7f73697363de0c0000']
      #@con.save data
      
  
    @dragListener.on 'dragend', (d) ->
      #Backbone.history.loadUrl
      console.log 'on end' 
      if d.type=='repository'
        return
      console.log 'selectedNode...'+that.selectedNode.label
      console.log 'draggingNode...'+that.draggingNode.label
      console.log 'Backbone.history.getFragment()'+Backbone.history.getFragment()
        


    deferred.promise()

  renderNodes: (root) ->
    #console.log 'nodes '+@layout.nodes
    #console.log 'nodes '+@layout.nodes.length
    nodes = @parent.selectAll('.concept-node')
      .data( @layout.nodes(root), (datum) -> datum.id )
      
    @createNodes nodes.enter()
    @deleteNodes nodes.exit()
    @updateNodes nodes
    
    #console.log 'nnodes..'+nodes
    nodes
  
  
  renderSiblings: (data) ->
    #console.log 'sibling...'+data
    siblings = @parent.selectAll('.sibling-node')
      .data( @layoutSiblings(data), (datum) -> datum.id )
    @createNodes siblings.enter()
    @deleteNodes siblings.exit()
    @updateNodes siblings
    siblings

  createNodes: (enter) ->
    that=@
    all = enter.append('g')
      .call(@dragListener)
      .on('mouseover', (d) ->
        #console.log 'over '+datum.label
        that.selectedNode=d
      )
      .on('mouseout', (d) ->
        #console.log 'over '+datum.label
        that.selectedNode=null
      )
      .attr('class', (datum) ->
        if datum.sibling then 'sibling-node' else 'concept-node'
      )
      .classed('repository-root', (datum) ->
        datum.type is 'repository'
      )

    nodes = all.filter(
      (datum) -> datum.type isnt 'placeholder'
    )

    nodes.append('title')

    links = nodes.append('a')
      .attr('xlink:href', (datum) ->
        datum.path
      )
      .on('mouseover', (datum) ->
        d3.select(@).classed 'hover', true
      )
      .on('mouseout', (datum) ->
        d3.select(@).classed 'hover', false
      )
      .on('click', (datum) ->
        d3.select(@).classed 'hover', false
      )

    links.append('rect').attr('class', 'background')
    links.append('circle').attr('class', 'bullet')
    links.append('text').attr('class', 'label')

    placeholders = all.filter(
      (datum) -> datum.type is 'placeholder'
    )

    placeholders.classed('placeholder', true)

    placeholders.append('title')

    placeholders.append('rect')
      .attr('class', 'count-background')
      .attr("y", '-0.55em')
      .attr("x", '12')
      .attr("height", '1.1em')
      .attr("rx", '0.5em')

    placeholders.append('text')
      .attr('class', 'count')
      .attr('text-anchor', 'start')
      .attr('x', '18')
      .attr('y', '4')

    placeholders.append('circle')
      .attr('class', 'background')

    placeholders.append('path')
      .attr('class', 'icon')
      .attr('d', 'M 0 -4 v 8 M -4 0 h 8')

    indicators = placeholders.append('g')
      .attr('class', 'progress-indicator')

    indicators.append('circle')
      .attr('class', 'track')
      .attr('r', '6')

    indicators.append('path')
      .attr('class', 'cursor')
      .attr('d', 'M 6 0 A 6 6 0 0 1 3 5.19')

    all

  deleteNodes: (exit) ->
    exit.each( (datum) =>
      if animation = datum.loop
        @parent.stopLoop animation
    )
    exit.remove()

  updateNodes: (all) ->
    all

    nodes = all.filter(
      (datum) -> datum.type isnt 'placeholder'
    )

    nodes
      .classed('hit', (datum) ->
        datum.hit
      )
      .classed('parent-of-hit', (datum) ->
        datum.parent_of_hit
      )
      .classed('new', (datum) ->
        not datum.id?
      )

    nodes.select('title')
      .text( (datum) ->
        datum.label
      )

    nodes.select('circle.bullet')
      .attr('r', (datum) ->
        if datum.hit then 2.8 else 2.5
      )

    nodes.select('rect.background')
      .attr('rx', (datum) ->
        if datum.type is 'repository' then 5 else null
      )
      .attr('filter', (datum) ->
        if datum.hit then 'url(#coreon-drop-shadow-filter)' else null
      )

    placeholders = all.filter(
      (datum) -> datum.type is 'placeholder'
    )

    placeholders.select('title')
      .text( (datum) ->
        if datum.label
          I18n.t 'panels.concept_map.placeholder.title',
            count: datum.label * 1
            label: datum.parent.label
      )

    placeholders.select('text.count')
      .text( (datum) ->
        datum.label
      )

    placeholders.select('rect.count-background')
      .style("display", (datum) ->
        'none' unless datum.label
      )

    placeholders.classed('busy', (datum) ->
      datum.busy
    )

    placeholders.select('circle.background')
      .attr('r', (datum) ->
        if datum.busy then 10 else 7
      )

    placeholders.select('path.icon')
      .style('display', (datum) ->
        if datum.busy then 'none' else null
      )

    placeholders.select('g.progress-indicator')
      .style('display', (datum) ->
        if datum.busy then null else 'none'
      )

    parent = @parent
    placeholders.select('path.cursor')
      .each( (datum) ->
        if datum.busy
          cursor = d3.select @
          datum.loop ?= parent.startLoop (animation) ->
            cursor.attr('transform', ->
              "rotate(#{animation.duration * 0.4 % 360})"
            )
        else
          parent.stopLoop datum.loop if datum.loop
      )

    all

  renderEdges: (edges) ->
    edges = @parent.selectAll('.concept-edge')
      .data(edges, (datum) ->
        "#{datum.source.id}|#{datum.target.id}"
      )
    @createEdges edges.enter()
    @deleteEdges edges.exit()
    @updateEdges edges
    edges

  createEdges: (enter) ->
    edges = enter.insert('path', '.concept-node')
      .attr('class', 'concept-edge')
    edges

  deleteEdges: (exit) ->
    exit.remove()

  updateEdges: (edges) ->
    edges

  updateLayout: (nodes, edges, deferred) =>
    placeholders = nodes.filter(
      (datum) -> datum.type is 'placeholder'
    )

    placeholders.select("text.count")
      .each( (datum) ->
        try
          datum.countWidth = @getBBox().width + 12
        catch
          "fail gracefully"
      )

    placeholders.select('rect.count-background')
      .attr("width", (datum) ->
        datum.countWidth
      )

    deferred.resolve nodes, edges


  box: (positions, width, height) ->
    box =
      x      : 0
      y      : 0
      width  : 0
      height : 0
    if pos = positions[0]
      box.x = pos.x
      box.y = pos.y

      for pos in positions[1..]
        l = Math.min pos.x, box.x
        r = Math.max pos.x, box.x + box.width
        t = Math.min pos.y, box.y
        b = Math.max pos.y, box.y + box.height
        w = r - l
        h = b - t

        if w < width and h < height
          box =
            x      : l
            y      : t
            width  : w
            height : h
        else
          break
    box
