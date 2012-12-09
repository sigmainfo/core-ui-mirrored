#= require environment
#= require views/simple_view
#= require templates/widgets/concept_map
#= require d3
#= require views/concepts/concept_node_view

class Coreon.Views.Widgets.ConceptMapView extends Coreon.Views.SimpleView

  id: "coreon-concept-map"

  className: "widget"

  template: Coreon.Templates["widgets/concept_map"]

  initialize: ->
    @layout = d3.layout.tree()
      .children( (d) -> d.treeDown )
      .size( [ 200, 320 ] )
    @model.on "hit:update hit:graph:update", @onHitUpdate, @

  render: ->
    @$el.html @template()
    @

  onHitUpdate: ->
    nodes = @layout.nodes @model.tree()
    @renderNodes nodes[1..], @scaleY(nodes)
    # @renderEdges @model.edges()

  renderNodes: (nodes, scaleY = 1) ->
    
    nodes = d3.select("##{@id} svg .concept-map")
      .selectAll(".concept-node")
      .data(nodes, (d) -> d.id )
    
    self = @

    nodes.enter()
      .append("svg:g")
      .each( (d) ->
        d.view = new Coreon.Views.Concepts.ConceptNodeView el: @, model: d.concept
        d.view.render()
      )

    nodes
      .each( (d) ->
        d.y = d.x * scaleY
        d.x = (d.depth - 1) * 100
      )
      .attr("transform", (d) -> "translate(#{d.x}, #{d.y})")
    
    nodes.exit()
      .each( (d) ->
        d.view?.dissolve()
        d.view = null
      )
      .remove()

  scaleY: (nodes) ->
    minDeltaY = 30
    for node in nodes
      minDeltaY = Math.min(node.children[1].x - node.children[0].x, minDeltaY) if node.children?.length >= 2
    scaleY = 30 / minDeltaY

  dissolve: ->
    @model.off null, null, @
