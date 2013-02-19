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
    @stencil = d3.svg.diagonal().projection (datum) -> [datum.y, datum.x]
    @stopListening()
    @listenTo @model, "reset add remove change:label", @render
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
      .data( data[1..], (datum) -> datum.model.cid )

    selection.enter()
      .append("svg:g")
      .attr("class", "concept-node")
      .each( (datum) ->
        view = new Coreon.Views.Concepts.ConceptNodeView
          el: @
          model: datum.model
        nodes[datum.model.cid] = view.render()
      )

    selection.exit()
      .each( (datum) ->
        nodes[datum.model.cid].stopListening()
        delete nodes[datum.model.cid]
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
      .data( data, (datum) -> "#{datum.source.model.cid}|#{datum.target.model.cid}" )
    
    selection.enter()
      .insert("svg:path", ".concept-node")
      .attr("class", "concept-edge")

    selection.exit()
      .remove()

    selection
      .attr("d", (datum) =>
        [source, target] = [datum.source, datum.target]
        [sourceBox, targetBox] = ( nodes[datum.model.cid].box() for datum in [source, target] )
        @stencil
          source:
            x: source.y + sourceBox.height / 2
            y: source.x + sourceBox.width
          target:
            x: target.y + sourceBox.height / 2
            y: target.x
      )

    @
