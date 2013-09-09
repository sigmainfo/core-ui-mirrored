#= require environment
#= require views/widgets/concept_map/render_strategy

class Coreon.Views.Widgets.ConceptMap.TopDown extends Coreon.Views.Widgets.ConceptMap.RenderStrategy

  # renderNodes: (root, options) ->
  #   @layout.size [ @size[1], @size[0] ]

  #   data  = @layout.nodes root
  #   views = @views

  #   nodes = @selection.selectAll(".concept-node")
  #     .data( data[1..], (datum) -> datum.model.cid )

  #   nodes.enter()
  #     .append("g")
  #     .attr("class", "concept-node")
  #     .each( (datum) ->
  #       view = new Coreon.Views.Widgets.ConceptMap.ConceptNodeListView
  #         el: @
  #         model: datum.model
  #       views[datum.model.cid] = view.render()
  #     )

  #   nodes.exit()
  #     .each( (datum) ->
  #       views[datum.model.cid].stopListening()
  #       delete views[datum.model.cid]
  #     )
  #     .remove()

  #   minY = @options.offsetY
  #   for datum in data
  #     if datum.children?.length > 1
  #       minY = Math.min minY, datum.children[1].x - datum.children[0].x
  #   scaleY = @options.offsetY / minY

  #   nodes
  #     .each( (datum) =>
  #       datum.y = datum.x * scaleY + @options.padding
  #       datum.x = ( datum.depth - 1 ) * @options.offsetX + @options.padding
  #     )
  #     .attr( "transform", (datum) ->
  #       "translate(#{datum.y}, #{datum.x})"
  #     )

  # renderEdges: (edges, options) ->

  #   edges = @selection.selectAll(".concept-edge")
  #     .data( edges, (datum) ->
  #       "#{datum.source.model.cid}|#{datum.target.model.cid}"
  #     )
  #   
  #   edges.enter()
  #     .insert("path", ".concept-node")
  #     .attr("class", "concept-edge")

  #   edges.exit()
  #     .remove()

  #   edges
  #     .attr("d", (datum) =>
  #       sourceBox = @views[datum.source.model.cid].box()
  #       @diagonal
  #         source:
  #           x: datum.source.y + sourceBox.height / 2
  #           y: datum.source.x + sourceBox.width
  #         target:
  #           x: datum.target.y + sourceBox.height / 2
  #           y: datum.target.x
  #     )
