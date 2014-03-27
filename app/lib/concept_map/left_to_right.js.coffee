#= require environment
#= require lib/concept_map/render_strategy
#= require helpers/text

class Coreon.Lib.ConceptMap.LeftToRight extends Coreon.Lib.ConceptMap.RenderStrategy

  constructor: (parent) ->
    super
    @layout
      .nodeSize([25, 260])
      .separation( (a, b) ->
        switch
          when a.parent is b.parent then 1
          when a.tail then 3
          else 2
      )
    @diagonal.projection (datum) -> [datum.y, datum.x]

  createNodes: (enter) ->
    super
      .attr("transform", (datum) ->
        "translate(#{datum.y}, #{datum.x})"
      )
      .style( 'opacity', 0 )

  updateNodes: (nodes) ->
    super
      .transition()
      .duration( 300 )
        .attr("transform", (datum) ->
          "translate(#{datum.y}, #{datum.x})"
        )
          .transition()
            .duration( 700 )
            .ease( 'cubic-out' )
              .style( 'opacity', 1 )

    nodes.select("text.label")
      .attr("text-anchor", "start")
      .attr("x", 7)
      .attr("y", "0.35em")
      .text( (datum) ->
        chars = if datum.hit then 27 else 34
        Coreon.Helpers.Text.shorten datum.label, chars
      )

    nodes.select("rect.background")
      .attr("height", (datum) ->
        if datum.hit then 20 else 17
      )
      .attr("width", (datum) ->
        datum.labelWidth ?= d3.select(@).attr('width') * 1
      )
      .attr("x", -7)
      .attr("y", (datum) ->
        if datum.hit then -11 else -8.5
      )

  createEdges: (edges) ->
    super
      .style( 'opacity', 0 )

  updateEdges: (edges) ->
    diagonal = @diagonal
    edges
      .transition()
      .duration( 300 )
        .attr("d", (datum) ->
          source = datum.source
          target = datum.target
          offsetTargetY = if datum.target.type is "placeholder"
            if datum.target.busy then 10 else 7
          else
            7
          diagonal
            source:
              x: source.x
              y: source.y + source.labelWidth - 7
            target:
              x: target.x
              y: target.y - offsetTargetY
        )
        .transition()
        .duration( 700 )
        .ease( 'cubic-out' )
          .style( 'opacity', 1 )

  updateLayout: (nodes, edges) ->
    nodes.select("text.label")
      .each( (datum) ->
        datum.labelWidth = @getBBox().width + 25
      )

    nodes.select("rect.background")
      .attr("width", (datum) ->
        datum.labelWidth
      )

    @updateEdges edges
    super

  center: (viewport, nodes = []) ->
    data = nodes.data()
    if data.length is 0
      x: -260
      y: 0
    else
      box = @box data, viewport.height, viewport.width
      x: -box.y - box.height / 2
      y: -box.x - box.width / 2

  layoutSiblings: (data) ->
    for datum in data
      datum.x = datum.sibling.x + 25
      datum.y = datum.sibling.y
    data
