#= require environment
#= require views/simple_view
#= require templates/widgets/concept_map
#= require d3
#= require views/concepts/concept_node_view
#= require models/hit

class Coreon.Views.Widgets.ConceptMapView extends Coreon.Views.SimpleView

  id: "coreon-concept-map"

  className: "widget"

  template: Coreon.Templates["widgets/concept_map"]

  options:
    size: [200, 320]
    offsetX: 120


  initialize: ->
    @nodes = {}
    @layout = d3.layout.tree()
    @stencil = d3.svg.diagonal().projection (d) -> [d.y, d.x]
    @stopListening()
    @listenTo @model, "change edge:in:add edge:in:remove", @render
    @_renderMarkupSkeleton()

  render: ->
    @_renderNodes()
    @_renderEdges()
    @

  _renderMarkupSkeleton: ->
    @$el.html @template size: @options.size

  _renderNodes: ->
    data = @layout.nodes @model.tree().root
    group = @$("svg g.concept-map").get 0
    nodes = @nodes

    selection = d3.select(group)
      .selectAll(".concept-node")
      .data( data[1..], (datum) -> datum.id )

    selection.enter()
      .append("svg:g")
      .attr("class", "concept-node")
      .each( (datum) ->
        console.log "enter: #{datum.id}"
        view = new Coreon.Views.Concepts.ConceptNodeView
          el: @
          model: datum.model
        nodes[datum.id] = view.render()
      )

    selection.exit()
      .each( (datum) ->
        console.log "exit: #{datum.id}"
        # nodes[datum.id].stopListening()
        # delete nodes[datum.id]
      )
      .remove()

    selection
      .each( (datum) =>
        datum.y = datum.x * @options.size[0]
        datum.x = ( datum.depth - 1 ) * @options.offsetX
      )
      .attr( "transform", (datum) ->
        "translate(#{datum.x}, #{datum.y})"
      )
    @

  _renderEdges: ->
    data = @model.tree().edges
    group = @$("svg g.concept-map").get 0
    nodes = @nodes

    selection = d3.select(group)
      .selectAll(".concept-edge")
      .data( data, (datum) -> "#{datum.source.id}->#{datum.target.id}" )
    
    selection.enter()
      .insert("svg:path", ".concept-node")
      .attr("class", "concept-edge")

    selection.exit()
      .remove()

    selection
      .each( (datum) ->
      )
    #   .attr("d", (datum) ->
    #     [source, target] = [datum.source, datum.target]
    #     [sourceBox, targetBox] = ( map.nodes[datum.id].box() for datum in [source, target] )
    #     map.stencil
    #       source:
    #         x: source.y + sourceBox.height / 2
    #         y: source.x + sourceBox.width
    #       target:
    #         x: target.y + sourceBox.height / 2
    #         y: target.x
    #   )

    @



  # renderMap: ->
  #   nodes = @layout.nodes @model.tree()
  #   @renderNodes nodes[1..], @scaleY(nodes)
  #   @renderEdges @model.edges()
  #   @centerY()

  # renderNodes: (nodes, scaleY = 1) ->
  #   nodes = d3.select( @$("svg .concept-map").get(0) )
  #     .selectAll(".concept-node")
  #     .data(nodes, (d) -> d.id )

  #   views = @views
  #   self = @
  #   
  #   nodes.enter()
  #     .append("svg:g")
  #     .each( (d) ->
  #       views[d.id] = new Coreon.Views.Concepts.ConceptNodeView
  #         el: @
  #         model: d.concept
  #       views[d.id].on "toggle:children", self.onToggleChildren, self
  #       views[d.id].on "toggle:parents", self.onToggleParents, self
  #     )

  #   nodes
  #     .each( (d) ->
  #       d.y = d.x * scaleY
  #       d.x = (d.depth - 1) * 120
  #       views[d.id].options.treeRoot = d.treeUp.length is 0
  #       views[d.id].options.treeLeaf = d.treeDown.length is 0
  #       views[d.id].render()
  #       d.box = d3.select(@).select(".background").node().getBBox()
  #     )
  #     .attr("transform", (d) -> "translate(#{d.x}, #{d.y})")
  #   
  #   nodes.exit()
  #     .each( (d) ->
  #       views[d.id].dissolve()
  #       delete views[d.id]
  #     )
  #     .remove()

  # renderEdges: (edges) ->
  #   edges = d3.select( @$("svg .concept-map").get(0) )
  #     .selectAll(".concept-edge")
  #     .data(edges, (d) -> "#{d.source.id}|#{d.target.id}")

  #   edges.enter()
  #     .insert("svg:path", ".concept-node")
  #     .attr("class", "concept-edge")

  #   edges.attr("d", (d) =>
  #     @stencil
  #       source:
  #         x: d.source.y + d.source.box.height / 2
  #         y: d.source.x + d.source.box.width
  #       target:
  #         x: d.target.y + d.source.box.height / 2
  #         y: d.target.x
  #   )

  #   edges.exit()
  #     .remove()
  #   

  # scaleY: (nodes) ->
  #   minDeltaY = 22
  #   for node in nodes
  #     minDeltaY = Math.min(node.children[1].x - node.children[0].x, minDeltaY) if node.children?.length >= 2
  #   scaleY = 22 / minDeltaY

  # centerY: ->
  #   map = @$("svg .concept-map").get(0)
  #   box = map.getBBox()
  #   deltaY = @size[0] - box.height
  #   y = if deltaY < 0 then deltaY / 2 else 0
  #   d3.select(map).attr("transform", "translate(10, #{y - 10})")

  # onToggleChildren: (node) ->
  #   if node.treeDown?.length > 0
  #     @collapseChildren node
  #   else
  #     @expandChildren node
  #   @renderMap()

  # collapseChildren: (root) ->
  #   nodes_to_check = root.treeDown
  #   ids_to_remove = []
  #   while node = nodes_to_check.shift()
  #     remove = true
  #     if node.parents?
  #       for parent in node.parents
  #         if ids_to_remove.indexOf(parent.id) < 0 and parent isnt root
  #           remove = false
  #           break
  #     if remove
  #       ids_to_remove.push node.id
  #       nodes_to_check.push node.treeDown...
  #   @model.graph().remove ids_to_remove... unless ids_to_remove.length is 0 

  # expandChildren: (node) ->
  #   ids = node.concept.get "sub_concept_ids"
  #   @model.graph().add ( new Coreon.Models.Hit id: id for id in ids )

  # onToggleParents: (node) ->
  #   console.log "toggle parents"
  #   ids = node.concept.get "super_concept_ids"
  #   @model.graph().add ( new Coreon.Models.Hit id: id, expandChildren: true for id in ids )
  #   @renderMap()

  # dissolve: ->
  #   @model.off null, null, @
