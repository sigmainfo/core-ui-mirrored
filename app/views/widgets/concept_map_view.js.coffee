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
    @renderNodes nodes[1..]

  renderNodes: (nodes) ->
    
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

    nodes.attr("transform", (d) -> "translate(#{(d.depth - 1) * 100}, #{d.x})")
    
    nodes.exit()
      .each( (d) ->
        d.view?.dissolve()
        d.view = null
      )
      .remove()

  dissolve: ->
    @model.off null, null, @
