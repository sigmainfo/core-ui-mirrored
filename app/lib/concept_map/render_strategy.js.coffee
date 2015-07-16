#= require environment
#= require d3
#= require helpers/repository_path

class Coreon.Lib.ConceptMap.RenderStrategy
  @tmp_nodes_dragged=undefined
  @tmp_nodes_selected=undefined
  @tmp_reset_nodes_selected=undefined
  @tmp_nodes_old_parent=[]
  @tmp_reset_nodes_dragged=undefined
  @need_to_save_first = false
  @current_models=[]
  @edit_mode_selected=false
  @delete_node
  @new_path
  @old_parent_element
  @new_parent_element
  @target_element
  @do_not_refresh=false
  @nodes
  @root_node
  @orientation_attr=1


  constructor: (@parent) ->
    @layout = d3.layout.tree()
    @diagonal = d3.svg.diagonal()
    @dragListener = d3.behavior.drag()
    @dragStarted = null
    @selectedNode=null
    @draggingNode=null
    @dragState=null

  resize: (@width, @height) ->

  initiateDrag: (d, domNode) ->
    @draggingNode=d
    svgGroup=d3.select('g.concept-map')
    that=@
    svgGroup.selectAll("g.concept-node").sort (a, b)->
      if a.id != that.draggingNode.id
        1
      else
        -1

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
      # console.log 'drag start...'
      that.dragState='dragStart'
      that.dragStarted= true;
      d3.event.sourceEvent.stopPropagation()
      if Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_dragged && Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_selected
        alert 'Save/Reset map before continuing'
        Coreon.Lib.ConceptMap.RenderStrategy.need_to_save_first = true
        return



    @dragListener.on 'drag', (d) ->
      # console.log 'drag ......'
      that.dragState='drag'
      if d.type=='repository' || d.type=='placeholder' || Coreon.Lib.ConceptMap.RenderStrategy.need_to_save_first
        return
      if Coreon.Lib.ConceptMap.RenderStrategy.edit_mode_selected == undefined || Coreon.Lib.ConceptMap.RenderStrategy.edit_mode_selected == false
        return
      if that.dragStarted
        domNode = that;
        that.initiateDrag(d, domNode);
      node=d3.select(@)
      d.x += d3.mouse(this)[0];
      d.y += d3.mouse(this)[1];
      node.attr("transform", "translate(" + d.x + "," + d.y+ ")");


    @dragListener.on 'dragend', (d) ->
      #Backbone.history.loadUrl
      # console.log 'drag state '+that.dragState
      if d.type=='repository'
        return
      if Coreon.Lib.ConceptMap.RenderStrategy.edit_mode_selected == undefined || Coreon.Lib.ConceptMap.RenderStrategy.edit_mode_selected == false
        return
      if that.dragState=='dragStart'
        that.dragState='dragEnd'
        return
      if that.selectedNode == null
        @graph=(new Coreon.Lib.TreeGraph Coreon.Lib.ConceptMap.RenderStrategy.current_models).generate()
        that.nodes    = that.renderNodes @graph.tree
        that.siblings = that.renderSiblings @graph.siblings
        that.edges    = that.renderEdges @graph.edges
        return

      if that.selectedNode.type!= 'placeholder' && that.draggingNode != null &&that.draggingNode!=undefined && Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_selected==undefined
        Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_dragged=that.draggingNode.id
        Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_selected=that.selectedNode.id
        if that.selectedNode.type=='repository'
          Coreon.Lib.ConceptMap.RenderStrategy.root_node=that.selectedNode.id
        @graph=(new Coreon.Lib.TreeGraph Coreon.Lib.ConceptMap.RenderStrategy.current_models).generate()
        that.nodes    = that.renderNodes @graph.tree
        that.siblings = that.renderSiblings @graph.siblings
        that.edges    = that.renderEdges @graph.edges
        $('.reset-map').removeClass('disable_buttons').removeAttr('disabled');
        $('.save-map').removeClass('disable_buttons').removeAttr('disabled');
    #collapse code
    collapse(graph.tree)
    deferred.promise()

  collapse=(d) ->
      if d.children
        d._children = d.children
        d._children.forEach collapse
        d.children = null
      return

# ---
# generated by js2coffee 2.0.4

  renderNodes: (root) ->
    nodes = @parent.selectAll('.concept-node')
      .data( @layout.nodes(root), (datum) -> datum.id  )
    @createNodes nodes.enter()
    @deleteNodes nodes.exit()
    @updateNodes nodes
    nodes


  renderSiblings: (data) ->
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
        if !Coreon.Lib.ConceptMap.RenderStrategy.need_to_save_first
         that.selectedNode=d
      )
      .on('mouseout', (d) ->
       if !Coreon.Lib.ConceptMap.RenderStrategy.need_to_save_first
        that.selectedNode=null
      )
      .attr('class', (datum) ->
        if datum.sibling then 'sibling-node' else 'concept-node concept-node_'+datum.id
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
    c1=nodes.append('circle').attr('class', (datum)->'negative-sign negative-sign-'+datum.id)
    if Coreon.Lib.ConceptMap.RenderStrategy.orientation_attr==1
       c1.attr('r','7').attr('cy','40').style('fill','#d6d9d5').style('stroke','none')
    else
       c1.attr('r','7').attr('cx',(datum)-> 40+datum.label.length).style('fill','#d6d9d5').style('stroke','none')

    c1.style('display',(datum)->
      if datum.children!=undefined && datum.children.length>0 && datum.type != 'repository'
          p=nodes.selectAll('line').data([datum])
          if Coreon.Lib.ConceptMap.RenderStrategy.orientation_attr==1
              p.enter().append('line').attr('x1',-2).attr('y1',40).attr('x2',2).attr('y2',40).attr("stroke-width", 2).attr("stroke", "#F8F8F6")
          if Coreon.Lib.ConceptMap.RenderStrategy.orientation_attr==2
              p.enter().append('line').attr('x1',(datum)-> 38+datum.label.length).attr('y1',0).attr('x2',(datum)-> 43 +datum.label.length).attr('y2',0).attr("stroke-width", 2).attr("stroke", "#F8F8F6")
          return 'inline-block'
      else
          return 'none'
      )


    placeholders = all.filter(
      (datum) -> datum.type is 'placeholder'
    )

    placeholders.classed('placeholder', (datum)->
      if datum.parent!=undefined
         $('.negative-sign-'+datum.parent.id).hide()
         $('.negative-sign-'+datum.parent.id).parent().find('line').hide()
      if datum.parent.children.length>0 && datum.parent.children[0].type!='placeholder'
         $('.negative-sign-'+datum.parent.id).show()
         $('.negative-sign-'+datum.parent.id).parent().find('line').show()
      return true
      )

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
    edges = enter.insert('path', '.concept-node').attr('class', (d) ->
       'concept-edge '+' path_'+d['source'].id+'_'+d['target'].id
    )

    #if Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_old_parent
    if Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_dragged && Coreon.Lib.ConceptMap.RenderStrategy.tmp_reset_nodes_dragged==undefined
        tmpp=Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_old_parent[0]+'_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_dragged
        tmpp1=Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_selected+'_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_dragged
        Coreon.Lib.ConceptMap.RenderStrategy.delete_node=d3.select('path.path_'+tmpp)
        Coreon.Lib.ConceptMap.RenderStrategy.new_path=d3.select('path.path_'+tmpp1)

        d3.select('path.path_'+tmpp).attr('class','concept-edge-dotted') #Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_old_parent[0]
        d3.select('path.path_'+tmpp1).attr('class','concept-edge concept-edge-new') #Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_old_parent[0]

        d3.select('g.concept-node_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_old_parent[0]).attr('class','concept-node concept-node_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_old_parent[0]+' old_parent')
        Coreon.Lib.ConceptMap.RenderStrategy.old_parent_element=d3.select('g.concept-node_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_old_parent[0])

        d3.select('g.concept-node_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_selected).attr('class','concept-node concept-node_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_selected+' new_parent')
        Coreon.Lib.ConceptMap.RenderStrategy.new_parent_element=d3.select('g.concept-node_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_selected)

        d3.select('g.concept-node_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_dragged).attr('class','concept-node concept-node_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_dragged+' dragged_node')
        Coreon.Lib.ConceptMap.RenderStrategy.target_element=d3.select('g.concept-node_'+Coreon.Lib.ConceptMap.RenderStrategy.tmp_nodes_dragged)

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
