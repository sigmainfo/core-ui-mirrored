#= require environment
#= require d3
#= require views/concepts/concept_node_view

class Coreon.Views.Widgets.ConceptMap.LeftToRight

  options:
    padding: 20
    offsetX: 190
    offsetY: 25
    size: [320, 240]

  constructor: (selection) ->
    @initialize arguments...

  initialize: (@selection, options = {}) ->
    options.size ?= @options.size
    @size = @_sizeWithoutPadding options.size
    @layout = d3.layout.tree()
    @stencil = d3.svg.diagonal().projection (datum) -> [datum.y, datum.x]
    @views = {}

  render: (tree, options = {}) ->
    @size = @_sizeWithoutPadding options.size if options.size?
    @renderNodes tree.root, options
    @renderEdges tree.edges, options

  renderNodes: (root, options) ->
    @layout.size [ @size[1], @size[0] ]

    data  = @layout.nodes root
    views = @views

    nodes = @selection.selectAll(".concept-node")
      .data( data[1..], (datum) -> datum.model.cid )

    nodes.enter()
      .append("g")
      .attr("class", "concept-node")
      .each( (datum) ->
        view = new Coreon.Views.Concepts.ConceptNodeView
          el: @
          model: datum.model
        views[datum.model.cid] = view.render()
      )

    nodes.exit()
      .each( (datum) ->
        views[datum.model.cid].stopListening()
        delete views[datum.model.cid]
      )
      .remove()

    minY = @options.offsetY
    for datum in data
      if datum.children?.length > 1
        minY = Math.min minY, datum.children[1].x - datum.children[0].x
    scaleY = @options.offsetY / minY

    nodes
      .each( (datum) =>
        datum.y = datum.x * scaleY + @options.padding
        datum.x = ( datum.depth - 1 ) * @options.offsetX + @options.padding
      )
      .attr( "transform", (datum) ->
        "translate(#{datum.x}, #{datum.y})"
      )

  renderEdges: (edges, options) ->
    data = for edge in edges
      continue unless @views[edge.source.model.cid]?
      continue unless @views[edge.target.model.cid]?
      edge

    edges = @selection.selectAll(".concept-edge")
      .data( data, (datum) ->
        "#{datum.source.model.cid}|#{datum.target.model.cid}"
      )
    
    edges.enter()
      .insert("path", ".concept-node")
      .attr("class", "concept-edge")

    edges.exit()
      .remove()

    edges
      .attr("d", (datum) =>
        [sourceBox, targetBox] = ( @views[node.model.cid].box() for key, node of datum )
        @stencil
          source:
            x: datum.source.y + sourceBox.height / 2
            y: datum.source.x + sourceBox.width
          target:
            x: datum.target.y + sourceBox.height / 2
            y: datum.target.x
      )
  #     .classed( "hit", (datum) ->
  #       datum.source.model.has("hit") and datum.target.model.has("hit")
  #     )
  #
  _sizeWithoutPadding: (sizeWithPadding) ->
    dimension - 2 * @options.padding for dimension in sizeWithPadding
