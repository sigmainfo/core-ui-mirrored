#= require environment
#= require views/widgets/concept_map/render_strategy

class Coreon.Views.Widgets.ConceptMap.TopDown extends Coreon.Views.Widgets.ConceptMap.RenderStrategy

  constructor: (parent) ->
    super
    @layout.nodeSize [190, 100]

  updateNodes: (nodes) ->
    super
    nodes.attr("transform", (datum) ->
      "translate(#{datum.x}, #{datum.y})"
    )

    nodes.select("text.label")
      .attr("text-anchor", "middle")
      .attr("x", "0")
      .attr("y", "17")
      .text( (datum) ->
        Coreon.Helpers.Text.shorten datum.label, 24
      )
      .each( (datum) ->
        datum.textBox = @.getBBox()
      )

    nodes.select("rect.background")
      .attr("height", (datum) ->
        datum.textBox.height + 6
      )
      .attr("width", (datum) ->
        datum.textBox.width + 10
      )
      .attr("x", (datum) ->
        datum.textBox.x - 5
      )
      .attr("y", (datum) ->
        offset = if datum.hit then 4 else 3
        datum.textBox.y - offset
      )

    nodes.select("g.toggle-parents")
      .attr("transform", (datum) ->
        "translate(0, -15) rotate(#{if datum.expandedIn then 90 else 0})" 
      )

    nodes.select("g.toggle-children")
      .attr("transform", (datum) ->
        paddingBottom = if datum.hit then 5 else 3
        "translate(0, #{datum.textBox.y + datum.textBox.height + 15}) rotate(#{if datum.expandedIn then 90 else 0})" 
      )

  updateEdges: (edges) ->
    diagonal = @diagonal
    edges.attr("d", (datum) ->
      paddingBottom = if datum.hit then 5 else 3
      diagonal
        source:
          x: datum.source.x
          y: datum.source.y + datum.source.textBox.y + datum.source.textBox.height + paddingBottom
        target:
          x: datum.target.x
          y: datum.target.y - 3.5
    )
