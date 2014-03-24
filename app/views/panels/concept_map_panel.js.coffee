#= require environment
#= require views/panels/panel_view
#= require templates/panels/concept_map
#= require helpers/titlebar
#= require d3
#= require lib/concept_map/left_to_right
#= require lib/concept_map/top_down
#= require modules/helpers
#= require modules/loop

class Coreon.Views.Panels.ConceptMapPanel extends Coreon.Views.Panels.PanelView

  id: 'coreon-concept-map'

  template: Coreon.Templates['panels/concept_map']

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
    super
    @navigator = d3.behavior.zoom()
      .scaleExtent(@options.scaleExtent)
      .on('zoom', @_panAndZoom)
    @_renderMarkupSkeleton()

    @renderStrategies = [
      Coreon.Lib.ConceptMap.TopDown
      Coreon.Lib.ConceptMap.LeftToRight
    ]

    @map = d3.select @$('svg g.concept-map')[0]
    Coreon.Modules.extend @map, Coreon.Modules.Loop
    @renderStrategy = new @renderStrategies[0] @map

    d3.select(@$('svg')[0]).call @navigator

    @hits = options.hits
    @listenTo @hits, 'update', @render
    @listenTo @model, 'placeholder:update', @update
    @listenTo @model, 'change', @scheduleForUpdate

  render: ->
    @rendering = on
    concepts = ( model.get 'result' for model in @hits.models )

    @model.build([]).done =>
      repository = @model.at(0)
      if placeholder = @model.at(1)
        placeholder.set 'busy', on
      @update().done @centerSelection

      @model.build(concepts).done =>
        @update().done (nodes) =>
          @centerSelection nodes, animate: yes
          @rendering = false
    @

  update: ->
    deferred = $.Deferred()
    @renderStrategy.render( @model.graph() ).done =>
      deferred.resolveWith @, arguments
    model.set 'rendered', yes for model in @model.models
    deferred.promise()

  scheduleForUpdate: (model) ->
    unless @rendering or not model.get('rendered')
      @rendering = on
      _.defer =>
        @update()
        @rendering = off

  padding: ->
    width = @panel.get('width')
    height = @canvasHeight()
    Math.min(width, height) * 0.1

  centerSelection: (nodes, options) ->
    width = @panel.get('width')
    height = @canvasHeight()
    padding = @padding()
    scale = @navigator.scale()

    viewport =
      width:  width  / scale - 2 * padding
      height: height / scale - 2 * padding

    hits = nodes
      .filter (datum) ->
        datum.hit
      .sort (a, b) ->
        diff = b.score - a.score
        if diff is 0
          a.label.localeCompare b.label
        else
          diff

    center = @renderStrategy.center viewport, hits

    offset =
      x: center.x * scale + padding
      y: center.y * scale + padding

    @navigator.translate [offset.x, offset.y]
    @_panAndZoom options

  expand: (event) ->
    @rendering = on
    node = $(event.target).closest '.placeholder'
    datum = d3.select(node[0]).datum()
    placeholder = @model.get datum.id
    placeholder.set 'busy', on
    @update()
    @model.expand(datum.parent.id)
      .always =>
        placeholder.set 'busy', off
        @update()
        @rendering = off

  zoomIn: ->
    zoom = Math.min @options.scaleExtent[1], @navigator.scale() + @options.scaleStep
    @navigator.scale zoom
    @_panAndZoom()

  zoomOut: ->
    zoom = Math.max @options.scaleExtent[0], @navigator.scale() - @options.scaleStep
    @navigator.scale zoom
    @_panAndZoom()

  canvasHeight: ->
    @panel.get('height') - @options.svgOffset

  resize: ->
    super

    width = @panel.get('width')
    height = @canvasHeight()

    svg = @$('svg')
    svg.attr
      width: "#{width}px"
      height: "#{height}px"

    @renderStrategy.resize width, height


  _renderMarkupSkeleton: ->
    @$el.html @template actions: [
      'panels.concept_map.toggle_orientation'
      'panels.concept_map.zoom_in'
      'panels.concept_map.zoom_out'
    ]

  _panAndZoom: (options = {}) =>
    map = @map
    if options.animate
      map = @map.transition()
        .delay(250)
        .duration(1000)

    map.attr('transform', "translate(#{@navigator.translate()}) scale(#{@navigator.scale()})")

  toggleOrientation: ->
    @currentRenderStrategy = if @currentRenderStrategy is 1 then 0 else 1
    views = @renderStrategy.views
    @renderStrategy = new @renderStrategies[@currentRenderStrategy] @map
    @renderStrategy.views = views
    @render()

  remove: ->
    @map.stopLoop()
    super
