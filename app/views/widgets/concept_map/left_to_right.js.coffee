#= require environment
#= require views/widgets/concept_map/render_strategy
#= require helpers/text

class Coreon.Views.Widgets.ConceptMap.LeftToRight extends Coreon.Views.Widgets.ConceptMap.RenderStrategy

  constructor: (parent) ->
    super
    @layout.nodeSize [25, 190]
    @diagonal.projection (datum) -> [datum.y, datum.x]

  updateNodes: (nodes) ->
    super
    nodes.attr("transform", (datum) ->
        "translate(#{datum.y}, #{datum.x})"
      )
    
    nodes.select("text.label")
      .attr("x", 7)
      .attr("y", "0.35em")
      .attr("text-anchor", "start")
      .each( (datum) ->
        d3.select(@).select("tspan").remove()
      )
      .text( (datum) ->
        Coreon.Helpers.Text.shorten datum.label, 24
      )
      .each( (datum) ->
        datum.textWidth = @getBBox().width
      )

    nodes.select("rect.background")
      .attr("height", (datum) ->
        if datum.hit then 20 else 17
      )
      .attr("width", (datum) ->
        datum.textWidth + 20
      )
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
        "translate(#{datum.textWidth + 21}, 0) rotate(#{if datum.expandedOut then 90 else 0})" 
      )

  updateEdges: (edges) ->
    diagonal = @diagonal
    edges.attr("d", (datum) ->
      diagonal
        source:
          x: datum.source.x
          y: datum.source.y + datum.source.textWidth + 14
        target:
          x: datum.target.x
          y: datum.target.y - 7
    )
