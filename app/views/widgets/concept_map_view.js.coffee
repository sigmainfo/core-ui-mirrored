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

    settings = Coreon.application?.repositorySettings('conceptMap')

    if settings.width?
      @resize settings.width, settings.height
    else
      @resize @options.size...
    d3.select(@$('svg')[0]).call @navigator

    @stopListening()
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
    Math.min(@width, @svgHeight) * 0.1

  centerSelection: (nodes, options) ->
    padding = @padding()
    viewport =
      width:  @width     / @navigator.scale() - 2 * padding
      height: @svgHeight / @navigator.scale() - 2 * padding
    hits = nodes
      .filter( (datum) -> datum.hit )
      .sort( (a, b) ->
        diff = b.score - a.score
        if diff is 0
          a.label.localeCompare b.label
        else
          diff
      )

    offset = @renderStrategy.center viewport, hits
    offset.x = offset.x * @navigator.scale() + padding
    offset.y = offset.y * @navigator.scale() + padding

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
    Coreon.application?.repositorySettings('conceptMap', layout)

  saveLayout: _.debounce saveLayout, 500

  _renderMarkupSkeleton: ->
    @$el.resizable 'destroy' if @$el.hasClass 'ui-resizable'
    @$el.html @template
    @$el.resizable
      handles: 's'
      minHeight: 80
      resize: (event, ui) =>
        @resize null, ui.size.height

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
