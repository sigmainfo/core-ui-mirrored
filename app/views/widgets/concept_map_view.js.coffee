#= require environment
#= require jquery.ui.resizable
#= require templates/widgets/concept_map
#= require d3
#= require views/widgets/concept_map/left_to_right
#= require views/widgets/concept_map/top_down
#= require modules/helpers
#= require modules/loop

class Coreon.Views.Widgets.ConceptMapView extends Backbone.View

  id: 'coreon-concept-map'

  className: 'widget'

  template: Coreon.Templates['widgets/concept_map']

  options:
    size: [320, 240]
    svgOffset: 22
    scaleExtent: [0.5, 2]
    scaleStep: 0.2

  events:
    'click .placeholder:not(.busy)' : 'expand'
    'click .zoom-in'                : 'zoomIn'
    'click .zoom-out'               : 'zoomOut'
    'click .toggle-orientation'     : 'toggleOrientation'

  initialize: (options = {}) ->
    @navigator = d3.behavior.zoom()
      .scaleExtent(@options.scaleExtent)
      .on('zoom', @_panAndZoom)
    @_renderMarkupSkeleton()

    @renderStrategies = [
      Coreon.Views.Widgets.ConceptMap.TopDown
      Coreon.Views.Widgets.ConceptMap.LeftToRight
    ]

    @map = d3.select @$('svg g.concept-map')[0]
    Coreon.Modules.extend @map, Coreon.Modules.Loop
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
    d3.select(@$('svg')[0]).call @navigator

    @stopListening()
    @hits = options.hits
    @listenTo @hits, 'update', @render
    @listenTo @model, 'placeholder:update', @update

  render: ->
    concepts = ( model.get 'result' for model in @hits.models )

    @model.build([]).done =>
      repository = @model.at(0)
      if placeholder = @model.at(1)
        placeholder.set 'busy', on
      @update()
      @centerSelection()

      @model.build(concepts).done =>
        @update()
        @centerSelection()
    @

  update: ->
    @renderStrategy.render @model.graph()
    @

  centerSelection: ->
    width = @width / 2
    height = @svgHeight / 2
    if @renderStrategy instanceof Coreon.Views.Widgets.ConceptMap.LeftToRight
      width -= 300
    else
      height -= 300
    @navigator.translate [width, height]
    @_panAndZoom()

  expand: (event) ->
    node = $(event.target).closest '.placeholder'
    datum = d3.select(node[0]).datum()
    placeholder = @model.get datum.id
    placeholder.set 'busy', on
    @update()
    @model.expand(datum.parent.id)
      .always =>
        placeholder.set 'busy', off
        @update()

  zoomIn: ->
    zoom = Math.min @options.scaleExtent[1], @navigator.scale() + @options.scaleStep
    @navigator.scale zoom
    @_panAndZoom()

  zoomOut: ->
    zoom = Math.max @options.scaleExtent[0], @navigator.scale() - @options.scaleStep
    @navigator.scale zoom
    @_panAndZoom()

  resize: (width, height) ->
    svg = @$('svg')
    if height?
      @height = height
      @svgHeight = height - @options.svgOffset
      @$el.height height
      svg.attr 'height', "#{@svgHeight}px"
    if width?
      @width = width
      @$el.width width
      svg.attr 'width', "#{ width }px"
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
    @$el.resizable 'destroy' if @$el.hasClass 'ui-resizable'
    @$el.html @template
    @$el.resizable
      handles: 's'
      minHeight: 80
      resize: (event, ui) =>
        @resize null, ui.size.height

  _panAndZoom: =>
    @map.attr('transform', "translate(#{@navigator.translate()}) scale(#{@navigator.scale()})")

  toggleOrientation: ->
    @currentRenderStrategy = if @currentRenderStrategy is 1 then 0 else 1
    views = @renderStrategy.views
    @renderStrategy = new @renderStrategies[@currentRenderStrategy] @map
    @renderStrategy.views = views
    @render()

  remove: ->
    @map.stopLoop()
    super
