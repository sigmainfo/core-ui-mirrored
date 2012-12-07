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
    @layout = d3.layout.tree().children (d) -> d.treeDown
    @model.on "hit:update", @onHitUpdate, @

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
   
    nodes.enter()
      .append("svg:g")
      .each( (d) ->
        d.view = new Coreon.Views.Concepts.ConceptNodeView el: @, model: d.concept
        d.view.render()
      )

    nodes.exit()
      .each( (d) ->
        d.view.destroy()
        d.view = null
      )

  dissolve: ->
    @model.off null, null, @
