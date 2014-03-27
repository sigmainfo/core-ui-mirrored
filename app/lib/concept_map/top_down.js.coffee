#= require environment
#= require lib/concept_map/render_strategy
#= require helpers/text

class Coreon.Lib.ConceptMap.TopDown extends Coreon.Lib.ConceptMap.RenderStrategy

  constructor: (parent) ->
    super
    @layout
      .nodeSize([160, 100])
      .separation( (a, b) ->
        switch
          when a.parent is b.parent then 1
          when a.tail then 2
          else 1.5
      )

  createNodes: (enter) ->
    super
      .attr("transform", (datum) ->
        "translate(#{datum.x}, #{datum.y})"
      )
      .style( 'opacity', 0 )

  updateNodes: (nodes) ->
    super
      .transition()
      .duration( 300 )
        .attr("transform", (datum) ->
          "translate(#{datum.x}, #{datum.y})"
        )
        .transition()
        .duration( 700 )
        .ease( 'cubic-out' )
          .style( 'opacity', 1 )

    labels = nodes.select("text.label")
      .attr("text-anchor", "middle")
      .attr("x", "0")
      .attr("y", (datum) ->
        if datum.hit then 21 else 20
      )

    labels
      .each( (datum) ->
        node = d3.select @
        chars = if datum.hit then 22 else 28
        lines = Coreon.Helpers.Text.wrap(datum.label, chars)[0..3]
        lineHeight = if datum.hit then 17 else 15
        paddingBottom = if datum.hit then 4 else 3
        datum.labelHeight = lines.length * lineHeight + paddingBottom
        node.text ""
        for line, number in lines
          node.append("tspan")
            .attr("x", 0)
            .attr("dy", (datum) ->
              lineHeight unless number is 0
            )
            .text(line)
      )

    nodes.select("rect.background")
      .attr("height", (datum) ->
        datum.labelHeight
      )
      .attr("y", (datum) ->
        if datum.hit then 6 else 7
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
          offsetTargetY = if datum.target.type is "placeholder"
            if datum.target.busy then 10 else 7
          else
            3.5
          diagonal
            source:
              x: datum.source.x
              y: datum.source.y + datum.source.labelHeight + 7
            target:
              x: datum.target.x
              y: datum.target.y - offsetTargetY
        )
        .transition()
        .duration( 700 )
        .ease( 'cubic-out' )
          .style( 'opacity', 1 )

  updateLayout: (nodes, edges) ->
    nodes.select("text.label")
      .each( (datum) ->
        datum.labelWidth = @getBBox().width + 16
      )

    nodes.select("rect.background")
      .attr("width", (datum) ->
        datum.labelWidth
      )
      .attr("x", (datum) ->
        datum.labelWidth / -2
      )

    @updateEdges edges
    super

  center: (viewport, nodes) ->
    data = nodes.data()
    if data.length is 0
      x: 0
      y: -100
    else
      box = @box data, viewport.width, viewport.height
      x: -box.x - box.width / 2
      y: -box.y - box.height / 2

  layoutSiblings: (data) ->
    for datum in data
      datum.x = datum.sibling.x + 100
      datum.y = datum.sibling.y
    data
