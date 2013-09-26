#= require environment
#= require views/widgets/concept_map/render_strategy
#= require helpers/text

class Coreon.Views.Widgets.ConceptMap.TopDown extends Coreon.Views.Widgets.ConceptMap.RenderStrategy

  constructor: (parent) ->
    super
    @layout
      .nodeSize([160, 100])
      .separation( (a, b) ->
        if a.parent is b.parent then 1 else 1.3
      )

  updateNodes: (nodes) ->
    super
    nodes
      .attr("transform", (datum) ->
        "translate(#{datum.x}, #{datum.y})"
      )

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

    nodes.select("g.toggle-parents")
      .attr("transform", (datum) ->
        "translate(0, -15) rotate(#{if datum.expandedIn then 0 else 90})" 
      )

    @updateToggleChildren nodes

  updateToggleChildren: (nodes) ->
    nodes.select("g.toggle-children")
      .attr("transform", (datum) ->
        "translate(0, #{datum.labelHeight + 20}) rotate(#{if datum.expandedOut then 0 else 90})" 
      )

  updateEdges: (edges) ->
    diagonal = @diagonal
    edges.attr("d", (datum) ->
      diagonal
        source:
          x: datum.source.x
          y: datum.source.y + datum.source.labelHeight + 7
        target:
          x: datum.target.x
          y: datum.target.y - 3.5
    )

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

    @updateToggleChildren nodes
    @updateEdges edges
