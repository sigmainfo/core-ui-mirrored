#= require environment
#= require views/simple_view
#= require templates/widgets/concept_map
#= require d3
#= require views/concepts/concept_node_view

class Coreon.Views.Widgets.ConceptMapView extends Coreon.Views.SimpleView

  id: "coreon-concept-map"

  className: "widget"

  template: Coreon.Templates["widgets/concept_map"]

  size: [200, 320]

  defaults:
    treeRoot: false
    treeLeaf: false

  initialize: ->
    @views = {}
    @layout = d3.layout.tree()
      .children( (d) -> d.treeDown )
      .size( @size )
    @stencil = d3.svg.diagonal()
      .projection (d) -> [d.y, d.x]
    @model.on "hit:update hit:graph:update", @onHitUpdate, @

  render: ->
    @$el.html @template size: @size
    @

  onHitUpdate: ->
    nodes = @layout.nodes @model.tree()
    @renderNodes nodes[1..], @scaleY(nodes)
    @renderEdges @model.edges()
    @centerY()

  renderNodes: (nodes, scaleY = 1) ->
    nodes = d3.select( @$("svg .concept-map").get(0) )
      .selectAll(".concept-node")
      .data(nodes, (d) -> d.id )

    views = @views
    self = @
    
    nodes.enter()
      .append("svg:g")
      .each( (d) ->
        views[d.id] = new Coreon.Views.Concepts.ConceptNodeView
          el: @
          model: d.concept
        views[d.id].on "toggle:children", self.onToggleChildren, self
      )

    nodes
      .each( (d) ->
        d.y = d.x * scaleY
        d.x = (d.depth - 1) * 120
        views[d.id].options.treeRoot = d.treeUp.length is 0
        views[d.id].options.treeLeaf = d.treeDown.length is 0
        views[d.id].render()
        d.box = d3.select(@).select(".background").node().getBBox()
      )
      .attr("transform", (d) -> "translate(#{d.x}, #{d.y})")
    
    nodes.exit()
      .each( (d) ->
        views[d.id].dissolve()
        delete views[d.id]
      )
      .remove()

  renderEdges: (edges) ->
    edges = d3.select( @$("svg .concept-map").get(0) )
      .selectAll(".concept-edge")
      .data(edges, (d) -> "#{d.source.id}|#{d.target.id}")

    edges.enter()
      .insert("svg:path", ".concept-node")
      .attr("class", "concept-edge")

    edges.attr("d", (d) =>
      @stencil
        source:
          x: d.source.y + d.source.box.height / 2
          y: d.source.x + d.source.box.width
        target:
          x: d.target.y + d.source.box.height / 2
          y: d.target.x
    )

    edges.exit()
      .remove()
    

  scaleY: (nodes) ->
    minDeltaY = 22
    for node in nodes
      minDeltaY = Math.min(node.children[1].x - node.children[0].x, minDeltaY) if node.children?.length >= 2
    scaleY = 22 / minDeltaY

  centerY: ->
    map = @$("svg .concept-map").get(0)
    box = map.getBBox()
    deltaY = @size[0] - box.height
    y = if deltaY < 0 then deltaY / 2 else 0
    d3.select(map).attr("transform", "translate(10, #{y - 10})")

  onToggleChildren: (node) ->
    ids = node.get "sub_concept_ids"
    if node.treeDown.length > 0
      @model.graph.reduce ids
    else
      @model.graph.expand ids

  dissolve: ->
    @model.off null, null, @
