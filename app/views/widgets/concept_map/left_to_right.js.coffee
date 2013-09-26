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
      .attr("width", (datum) ->
        datum.labelWidth
      )
      .attr("x", -7)
      .attr("y", (datum) ->
        if datum.hit then -11 else -8.5
      )
    
    nodes.select("g.toggle-parents")
      .attr("transform", (datum) ->
        "translate(-15, 0) rotate(#{if datum.expandedIn then 90 else 0})" 
      )

    @updateToggleChildren nodes

  updateEdges: (edges) ->
    diagonal = @diagonal
    edges.attr("d", (datum) ->
      source = datum.source
      target = datum.target
      if labelWidth = source.labelWidth
        diagonal
          source:
            x: source.x
            y: source.y + labelWidth - 7
          target:
            x: target.x
            y: target.y - 7
      else
        "m 0,0"
    )

  updateToggleChildren: (nodes) ->
    nodes.select("g.toggle-children")
      .attr("transform", (datum) ->
        if labelWidth = datum.labelWidth
          "translate(#{datum.labelWidth}, 0) rotate(#{if datum.expandedOut then 90 else 0})" 
        else
          null
      )


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
    @updateToggleChildren nodes
