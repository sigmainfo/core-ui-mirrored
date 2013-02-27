#= require environment
#= require jquery.ui.resizable
#= require views/simple_view
#= require templates/widgets/concept_map
#= require d3
#= require views/concepts/concept_node_view
#= require models/hit

class Coreon.Views.Widgets.ConceptMapView extends Coreon.Views.SimpleView

  id: "coreon-concept-map"

  className: "widget"

  template: Coreon.Templates["widgets/concept_map"]

  options:
    size: [240, 320]
    scaleExtent: [0.5, 2]
    scaleStep: 0.2
    padding: 20
    offsetX: 100
    offsetY: 22

  events:
    "click .zoom-in":  "zoomIn"
    "click .zoom-out": "zoomOut"

  initialize: (options = {}) ->
    @views = {}
    @layout = d3.layout.tree()
    @stencil = d3.svg.diagonal().projection (datum) -> [datum.y, datum.x]
    @navigator = d3.behavior.zoom()
      .scaleExtent(@options.scaleExtent)
      .on("zoom", @_panAndZoom)
    @stopListening()
    @listenTo @model, "reset add remove change:label", _.debounce(@render, options.renderInterval ?= 100)
    @_renderMarkupSkeleton()
    d3.select(@$("svg").get 0).call @navigator

  render: ->
    @_renderNodes()
    @_renderEdges()
    @

  zoomIn: ->
    zoom = Math.min @options.scaleExtent[1], @navigator.scale() + @options.scaleStep
    @navigator.scale zoom
    @_panAndZoom()

  zoomOut: ->
    zoom = Math.max @options.scaleExtent[0], @navigator.scale() - @options.scaleStep
    @navigator.scale zoom
    @_panAndZoom()


  _renderMarkupSkeleton: ->
    @$el.resizable "destroy" if @$el.hasClass "ui-resizable"
    @$el.html @template size: @options.size
    svgHeightOffset = null
    @$el.resizable
      handles: "s"
      minHeight: 80
      start: (event, ui) =>
        svgHeightOffset = @$el.height() - $("svg").height()
      resize: (event, ui) =>
        svg = @$("svg")
        @$("svg").attr "height", ui.size.height - svgHeightOffset

  _renderNodes: ->
    @layout.size [
      @options.size[0]
      @options.size[1] - 2 * @options.padding
    ]
    views = @views
    data = @layout.nodes @model.tree().root

    @navigator.translate([ @options.padding, 0 ])
    @group = d3.select(@$("svg g.concept-map").get 0)
      .attr("transform", "translate(#{@options.padding}, 0)")


    selection = @group.selectAll(".concept-node")
      .data( data[1..], (datum) -> datum.model.cid )

    selection.enter()
      .append("svg:g")
      .attr("class", "concept-node")
      .each( (datum) ->
        view = new Coreon.Views.Concepts.ConceptNodeView
          el: @
          model: datum.model
        views[datum.model.cid] = view.render()
      )

    selection.exit()
      .each( (datum) ->
        views[datum.model.cid].stopListening()
        delete views[datum.model.cid]
      )
      .remove()

    minY = @options.offsetY
    for datum in data
      if datum.children?.length > 1
        minY = Math.min minY, datum.children[1].x - datum.children[0].x
    scaleY = @options.offsetY / minY

    selection
      .each( (datum) =>
        datum.y = datum.x * scaleY
        datum.x = ( datum.depth - 1 ) * @options.offsetX
      )
      .attr( "transform", (datum) ->
        "translate(#{datum.x}, #{datum.y})"
      )
    @

  _renderEdges: ->
    data = for edge in @model.tree().edges
      continue unless @views[edge.source.model.cid]?
      continue unless @views[edge.target.model.cid]?
      edge
    selection = @group.selectAll(".concept-edge")
      .data( data, (datum) ->
        "#{datum.source.model.cid}|#{datum.target.model.cid}"
      )
    
    selection.enter()
      .insert("svg:path", ".concept-node")
      .attr("class", "concept-edge")

    selection.exit()
      .remove()

    selection
      .attr("d", (datum) =>
        [source, target] = [datum.source, datum.target]
        [sourceBox, targetBox] = ( @views[datum.model.cid].box() for datum in [source, target] )
        @stencil
          source:
            x: source.y + sourceBox.height / 2
            y: source.x + sourceBox.width
          target:
            x: target.y + sourceBox.height / 2
            y: target.x
      )

    @
  
  _panAndZoom: =>
    @group?.attr("transform", "translate(#{@navigator.translate()}) scale(#{@navigator.scale()})")
