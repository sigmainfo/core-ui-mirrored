#= require environment
#= require views/widgets/concept_map/render_strategy
#= require helpers/text

class Coreon.Views.Widgets.ConceptMap.TopDown extends Coreon.Views.Widgets.ConceptMap.RenderStrategy

  constructor: (parent) ->
    super
    @layout.nodeSize [150, 100]

  updateNodes: (nodes) ->
    super
    nodes.attr("transform", (datum) ->
      "translate(#{datum.x}, #{datum.y})"
    )

    nodes.select("text.label")
      .attr("text-anchor", "middle")
      .attr("x", "0")
      .attr("y", (datum) ->
        if datum.hit then 21 else 20
      )
      .text( (datum) ->
        chars = if datum.hit then 27 else 34
        Coreon.Helpers.Text.shorten datum.label, chars
      )

    nodes.select("rect.background")
      .attr("height", (datum) ->
        if datum.hit then 20 else 19
      )
      .attr("width", 140)
      .attr("x", -70)
      .attr("y", (datum) ->
        if datum.hit then 6 else 7
      )

    nodes.select("g.toggle-parents")
      .attr("transform", (datum) ->
        "translate(0, -15) rotate(#{if datum.expandedIn then 90 else 0})" 
      )

    nodes.select("g.toggle-children")
      .attr("transform", (datum) ->
        "translate(0, 35) rotate(#{if datum.expandedOut then 90 else 0})" 
      )

  updateEdges: (edges) ->
    diagonal = @diagonal
    edges.attr("d", (datum) ->
      diagonal
        source:
          x: datum.source.x
          y: datum.source.y + 26
        target:
          x: datum.target.x
          y: datum.target.y - 3.5
    )
