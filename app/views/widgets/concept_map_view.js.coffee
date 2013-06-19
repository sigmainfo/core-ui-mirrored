#= require environment
#= require jquery.ui.resizable
#= require views/simple_view
#= require templates/widgets/concept_map
#= require d3
#= require views/widgets/concept_map/left_to_right

class Coreon.Views.Widgets.ConceptMapView extends Coreon.Views.SimpleView

  id: "coreon-concept-map"

  className: "widget"

  template: Coreon.Templates["widgets/concept_map"]

  options:
    size: [320, 240]
    svgOffset: 22
    scaleExtent: [0.5, 2]
    scaleStep: 0.2

  events:
    "click .zoom-in":  "zoomIn"
    "click .zoom-out": "zoomOut"

  initialize: (options = {}) ->
    @navigator = d3.behavior.zoom()
      .scaleExtent(@options.scaleExtent)
      .on("zoom", @_panAndZoom)
    @stopListening()
    @listenTo @model, "reset add remove change:label", _.throttle(@render, 100)
    @_renderMarkupSkeleton()
    # if session = Coreon.application?.session.get @id
    #   @resize session.width, session.height
    # else
    @resize @options.size...
    d3.select(@$("svg").get 0).call @navigator
    @map = d3.select(@$("svg g.concept-map").get 0)
    @renderStrategy = new Coreon.Views.Widgets.ConceptMap.LeftToRight @map

  render: ->
    @renderStrategy.render @model.tree(), size: [@_svgWidth, @_svgHeight]
    @

  zoomIn: ->
    zoom = Math.min @options.scaleExtent[1], @navigator.scale() + @options.scaleStep
    @navigator.scale zoom
    @_panAndZoom()

  zoomOut: ->
    zoom = Math.max @options.scaleExtent[0], @navigator.scale() - @options.scaleStep
    @navigator.scale zoom
    @_panAndZoom()

  resize: (width, height) ->
    svg = @$("svg")
    if height?
      @$el.height height
      @_svgHeight = height - @options.svgOffset
      svg.attr "height", "#{ height - @options.svgOffset }px"
    if width?
      @$el.width width
      @_svgWidth = width
      svg.attr "width", "#{ width }px"
    @saveLayout width: @$el.width(), height: @$el.height()
    
  saveLayout = (layout) -> 
    # if Coreon.application?
    #   Coreon.application?.session.save @id, layout

  saveLayout: _.debounce saveLayout, 500

  _renderMarkupSkeleton: ->
    @$el.resizable "destroy" if @$el.hasClass "ui-resizable"
    @$el.html @template
    @$el.resizable
      handles: "s"
      minHeight: 80
      resize: (event, ui) =>
        @resize null, ui.size.height

  _panAndZoom: =>
    @map.attr("transform", "translate(#{@navigator.translate()}) scale(#{@navigator.scale()})")
