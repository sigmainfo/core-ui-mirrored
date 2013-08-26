#= require environment
#= require d3

class Coreon.Views.Widgets.ConceptMap.RenderStrategy

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
    @views = {}

  render: (tree, options = {}) ->
    @size = @_sizeWithoutPadding options.size if options.size?
    @renderNodes tree.root, options
    @renderEdges tree.edges, options

  renderNodes: (root, options) ->

  renderEdges: (edges, options) ->

    edges = @selection.selectAll(".concept-edge")
      .data( edges, (datum) ->
        "#{datum.source.model.cid}|#{datum.target.model.cid}"
      )
    
    edges.enter()
      .insert("path", ".concept-node")
      .attr("class", "concept-edge")

    edges.exit()
      .remove()

    edges
      .attr("d", (datum) =>
        sourceBox = @views[datum.source.model.cid].box()
        @stencil
          source:
            x: datum.source.y + sourceBox.height / 2
            y: datum.source.x + sourceBox.width
          target:
            x: datum.target.y + sourceBox.height / 2
            y: datum.target.x
      )
  
  _sizeWithoutPadding: (sizeWithPadding) ->
    dimension - 2 * @options.padding for dimension in sizeWithPadding
