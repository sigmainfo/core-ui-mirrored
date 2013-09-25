#= require environment
#= require views/widgets/concept_map/render_strategy
#= require helpers/text

class Coreon.Views.Widgets.ConceptMap.LeftToRight extends Coreon.Views.Widgets.ConceptMap.RenderStrategy

  constructor: (parent) ->
    super
    @layout.nodeSize [25, 260]
    @diagonal.projection (datum) -> [datum.y, datum.x]

  updateNodes: (nodes) ->
    super
    nodes.attr("transform", (datum) ->
        "translate(#{datum.y}, #{datum.x})"
      )
    
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
      .attr("width", 200)
      .attr("x", -7)
      .attr("y", (datum) ->
        if datum.hit then -10 else -8.5
      )
    
    nodes.select("g.toggle-parents")
      .attr("transform", (datum) ->
        "translate(-15, 0) rotate(#{if datum.expandedIn then 90 else 0})" 
      )

    nodes.select("g.toggle-children")
      .attr("transform", (datum) ->
        "translate(200, 0) rotate(#{if datum.expandedOut then 90 else 0})" 
      )

  updateEdges: (edges) ->
    diagonal = @diagonal
    edges.attr("d", (datum) ->
      diagonal
        source:
          x: datum.source.x
          y: datum.source.y + 193
        target:
          x: datum.target.x
          y: datum.target.y - 7
    )
