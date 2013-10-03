#= require environment
#= require jquery.ui.resizable
#= require views/simple_view
#= require templates/widgets/concept_map
#= require d3
#= require views/widgets/concept_map/left_to_right
#= require views/widgets/concept_map/top_down

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
    "click .toggle-orientation": "toggleOrientation"

  initialize: (options = {}) ->
    @navigator = d3.behavior.zoom()
      .scaleExtent(@options.scaleExtent)
      .on("zoom", @_panAndZoom)
    @_renderMarkupSkeleton()

    @renderStrategies = [
      Coreon.Views.Widgets.ConceptMap.TopDown
      Coreon.Views.Widgets.ConceptMap.LeftToRight
    ]

    @map = d3.select(@$("svg g.concept-map").get 0)
    @renderStrategy = new @renderStrategies[0] @map

    settings = {}
    if cache_id = Coreon.application?.cacheId()
      try
        settings = JSON.parse localStorage.getItem cache_id
      finally
        settings ?= {}
    settings.conceptMap ?= {}
    if settings.conceptMap.width?
      @resize settings.conceptMap.width, settings.conceptMap.height
    else
      @resize @options.size...
    d3.select(@$("svg").get 0).call @navigator

    @stopListening()
    @listenTo @model, "add remove change:label change:hit", @render
    @listenTo @model, "reset", @renderAndCenterSelection

  render: ->
    @renderStrategy.render @model.tree()
    @

  renderAndCenterSelection: ->
    width = @width / 2
    height = @svgHeight / 2
    if @renderStrategy instanceof Coreon.Views.Widgets.ConceptMap.LeftToRight
      width -= 300
    else
      height -= 300
    @navigator.translate [width, height]
    @_panAndZoom()
    @render()
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
      @height = height
      @svgHeight = height - @options.svgOffset 
      @$el.height height
      svg.attr "height", "#{@svgHeight}px"
    if width?
      @width = width
      @$el.width width
      svg.attr "width", "#{ width }px"
    @renderStrategy.resize @width, @height - @options.svgOffset
    @saveLayout width: @width, height: @height
    
  saveLayout = (layout) ->
    settings = {}
    if cache_id = Coreon.application?.cacheId?()
      settings = JSON.parse(localStorage.getItem(cache_id)) or {}
      settings.conceptMap = layout
      localStorage.setItem cache_id, JSON.stringify settings

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

  toggleOrientation: ->
    @currentRenderStrategy = if @currentRenderStrategy is 1 then 0 else 1
    views = @renderStrategy.views
    @renderStrategy = new @renderStrategies[@currentRenderStrategy] @map
    @renderStrategy.views = views
    @renderAndCenterSelection()
