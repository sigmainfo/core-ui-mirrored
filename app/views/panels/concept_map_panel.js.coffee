#= require environment
#= require views/panels/panel_view
#= require templates/panels/concept_map
#= require helpers/titlebar_editmap
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
    'click .edit-map'               : 'editMap'
    'click .reset-map'              : 'resetMap'
    'click .cancel-map'             : 'cancelMap'
    'click .save-map'               : 'saveMap'
    'click .maximize'               : 'MaximizeConceptPanel'
    'click circle.negative-sign'    : 'collapse'
    #'click .concept-node circle.negative-sign'   : 'collapse'

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

    @origin = d3.select @$('svg g.origin')[0]

    @map = d3.select @$('svg g.concept-map')[0]
    Coreon.Modules.extend @map, Coreon.Modules.Loop
    @renderStrategy = new @renderStrategies[0] @map

    d3.select(@$('svg')[0]).call @navigator

    @hits = options.hits
    @listenTo @hits, 'update', @render
    @listenTo @model, 'placeholder:update', @update
    @listenTo @model, 'change', @scheduleForUpdate

  render: ->
    if !window.do_not_refresh || window.do_not_refresh == undefined
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

            # Hide/Show edit icons
            if $('#coreon-concept-map').parent().attr('id') != 'coreon-main'
              $('.edit-map').hide();
      @
    else
      window.do_not_refresh = false

#  render: ->
#    @rendering = on
#    concepts = ( model.get 'result' for model in @hits.models )
#
#    @model.build([]).done =>
#      repository = @model.at(0)
#      if placeholder = @model.at(1)
#        placeholder.set 'busy', on
#      @update().done @centerSelection
#
#      @model.build(concepts).done =>
#        @update().done (nodes) =>
#          @centerSelection nodes, animate: yes
#          @rendering = false
#
#          # Hide/Show edit icons
#          if $('#coreon-concept-map').parent().attr('id') != 'coreon-main'
#            $('.edit-map').hide();
#
#    @

  update: ->
    console.log 'update called ***'
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

  padding: (width, height) ->
    relative = Math.min(width, height) * 0.1
    Math.min relative, 100

  centerSelection: (nodes, options) ->
    {width, height} = @dimensions()
    padding = @padding width, height
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
      x: center.x * scale
      y: center.y * scale

    @navigator.translate [offset.x, offset.y]
    @_panAndZoom options

  expand: (event) ->
    @rendering = on
    node = $(event.target).closest '.placeholder'
    datum = d3.select(node[0]).datum()
    placeholder = @model.get datum.id
    console.log 'placeholder ,,, '+JSON.stringify(placeholder)
    placeholder.set 'busy', on
    @update()
    console.log 'datum.parent.id ... '+datum.parent.id
    console.log 'datum.parent.id ... '+datum.parent.label
    @model.expand(datum.parent.id)
      .always =>
        placeholder.set 'busy', off
        @update()
        @rendering = off

  collapse: (event) ->
    console.log 'clicked collapse event'
    @rendering = off
    node = $(event.target).closest '.negative-sign'
    datum = d3.select(node[0]).datum()
    placeholder = @model.get datum.id
    placeholder.set 'busy', off
    @update()
    @model.collapse(datum.id)
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

  @hello = true

  editMap: ->
    #console.log 'editmap clicked'
    if $('#coreon-concept-map').parent().attr('id') == 'coreon-main'
      if window.edit_mode_selected
        window.edit_mode_selected = false
        $("body").removeClass('edit_mode');
        $('.edit-map').removeClass('edit_pressed');
        $('.submit_concept').hide();

        # Resetting all custom variables
        window.tmp_nodes_old_parent=[]
        window.tmp_nodes_dragged=undefined
        window.tmp_nodes_selected=undefined
        window.tmp_reset_nodes_dragged=undefined
        window.tmp_reset_nodes_selected=undefined
        window.need_to_save_first = false

        # Reloading Graph
        @graph=(new Coreon.Lib.TreeGraph window.models).generate()
        console.log 'graph is *** :'+@graph
        @renderStrategy.nodes    = @renderStrategy.renderNodes @graph.tree
        @renderStrategy.siblings = @renderStrategy.renderSiblings @graph.siblings
        @renderStrategy.edges    = @renderStrategy.renderEdges @graph.edges

        # Disabling save/reset buttons
        $('.reset-map').addClass('disable_buttons').attr('disabled','disabled');
        $('.save-map').addClass('disable_buttons').attr('disabled','disabled');

      else
        window.edit_mode_selected = true
        $('.edit-map').addClass('edit_pressed');
        $("body").addClass('edit_mode');
        $('.submit_concept').show();

  saveMap: ->
    #console.log 'save called ******'
#    console.log 'save clicked'+window.tmp_nodes_dragged
    if window.edit_mode_selected && window.tmp_nodes_dragged
      @con=Coreon.Models.Concept.find(window.tmp_nodes_dragged)
      data =
          superconcept_ids: [window.tmp_nodes_selected]
      @con.save data

      ###tmpp=window.tmp_nodes_old_parent[0]+'_'+window.tmp_nodes_dragged
      console.log 'tmpp :'+tmpp
      d3.selectAll('concept-edge1').remove()
      ###
      $('.reset-map').addClass('disable_buttons').attr('disabled','disabled')
      $('.save-map').addClass('disable_buttons').attr('disabled','disabled')
      if window.delete_node
         window.delete_node.attr('class','concept-edge-hide')
      window.tmp_reset_nodes_dragged=window.tmp_nodes_dragged
      window.tmp_reset_nodes_selected=window.tmp_nodes_selected
      window.tmp_nodes_dragged=undefined
      window.tmp_nodes_selected=undefined
      window.need_to_save_first = false
      window.tmp_reset_nodes_dragged=undefined


#      @graph=(new Coreon.Lib.TreeGraph window.models).generate()
#      @renderStrategy.nodes    = @renderStrategy.renderNodes @graph.tree
#      @renderStrategy.siblings = @renderStrategy.renderSiblings @graph.siblings
#      @renderStrategy.edges    = @renderStrategy.renderEdges @graph.edges



#      $("body").css("background","url('/assets/layout/bg.jpg')");
#      window.edit_mode_selected = false

  resetMap: ->
     # console.log 'reset called ******'
    #console.log 'reset clicked '+window.tmp_reset_nodes_dragged
#    if window.edit_mode_selected && window.tmp_reset_nodes_dragged
#      @con=Coreon.Models.Concept.find(window.tmp_reset_nodes_dragged)
#      data =
#          superconcept_ids: window.tmp_nodes_old_parent
#      @con.save data
#      window.tmp_reset_nodes_dragged=undefined
#      window.tmp_reset_nodes_selected=undefined
#      window.tmp_nodes_old_parent=[]

      if window.edit_mode_selected
        window.tmp_nodes_old_parent=[]
        window.tmp_nodes_dragged=undefined
        window.tmp_nodes_selected=undefined
        window.tmp_reset_nodes_dragged=undefined
        window.tmp_reset_nodes_selected=undefined
        window.need_to_save_first = false

        $('.reset-map').addClass('disable_buttons').attr('disabled','disabled');
        $('.save-map').addClass('disable_buttons').attr('disabled','disabled');

        if window.delete_node
         window.delete_node.attr('class','concept-edge-hide')

        @graph=(new Coreon.Lib.TreeGraph window.models).generate()
        @renderStrategy.nodes    = @renderStrategy.renderNodes @graph.tree
        @renderStrategy.siblings = @renderStrategy.renderSiblings @graph.siblings
        @renderStrategy.edges    = @renderStrategy.renderEdges @graph.edges

  cancelMap: ->
    #console.log 'cancel clicked'+@renderStrategy
    if window.edit_mode_selected
      window.tmp_nodes_old_parent=[]
      window.tmp_nodes_dragged=undefined
      window.tmp_nodes_selected=undefined
      window.tmp_reset_nodes_dragged=undefined
      window.tmp_reset_nodes_selected=undefined
      window.need_to_save_first = false

      $('.reset-map').addClass('disable_buttons').attr('disabled','disabled');
      $('.save-map').addClass('disable_buttons').attr('disabled','disabled');

      if window.delete_node
        window.delete_node.attr('class','concept-edge-hide')

      window.edit_mode_selected = false
      $('.edit-map').removeClass('edit_pressed');
      $("body").removeClass('edit_mode');
      $('.submit_concept').hide();

      @graph=(new Coreon.Lib.TreeGraph window.models).generate()
      @renderStrategy.nodes    = @renderStrategy.renderNodes @graph.tree
      @renderStrategy.siblings = @renderStrategy.renderSiblings @graph.siblings
      @renderStrategy.edges    = @renderStrategy.renderEdges @graph.edges



  dimensions: ->
    width: @$el.innerWidth()
    height: @$el.innerHeight()

  resize: ->
    super

    {width, height} = @dimensions()

    unless @panel.get('widget')
      @$el.attr 'style', null

    @origin.attr 'transform'
      , "translate(#{width / 2}, #{height / 2})"
    @renderStrategy.resize width, height

  _renderMarkupSkeleton: ->
    @$el.html @template actions: [
      'panels.concept_map.toggle_orientation'
      'panels.concept_map.zoom_in'
      'panels.concept_map.zoom_out'
      'panels.concept_map.edit_map'
#      'panels.concept_map.reset_map'
#      'panels.concept_map.cancel_map'
#      'panels.concept_map.save_map'
    ]

  _panAndZoom: (options = {}) =>
    map = @map
    if options.animate
      map = @map.transition()
        .delay(250)
        .duration(1000)

    [x, y] = @navigator.translate()

    map.attr 'transform'
      , "translate(#{@navigator.translate()}) scale(#{@navigator.scale()})"

  toggleOrientation: ->
    @currentRenderStrategy = if @currentRenderStrategy is 1 then 0 else 1
    views = @renderStrategy.views
    @renderStrategy = new @renderStrategies[@currentRenderStrategy] @map
    @renderStrategy.views = views
    @map.selectAll('*').remove()
    @render()

  remove: ->
    @map.stopLoop()
    super

  MaximizeConceptPanel: ->
    $('.edit-map').show();
