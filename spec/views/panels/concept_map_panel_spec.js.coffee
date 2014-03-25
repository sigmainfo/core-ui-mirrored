#= require spec_helper
#= require views/panels/concept_map_panel

describe 'Coreon.Views.Panels.ConceptMapPanel', ->

  no_rAF = no
  nodes = null
  hits = null
  view = null
  panel = null

  before ->
    unless window.requestAnimationFrame?
      no_rAF = yes
      window.requestAnimationFrame = ->
      window.cancelAnimationFrame = ->

  after ->
    if no_rAF
      delete window.requestAnimationFrame
      delete window.cancelAnimationFrame

  beforeEach ->
    sinon.stub I18n, 't'
    Coreon.application =
      cacheId: -> 'face42'
      repositorySettings: (key = null) ->
        setting: key

    nodes = new Backbone.Collection

    nodes.build = =>
      nodes.add [
        new Backbone.Model type: 'repository'
        new Backbone.Model type: 'placeholder'
      ]
      @deferred = $.Deferred()
      @deferred.promise()

    nodes.graph = ->
      tree:
        children: []
      edges: []

    hits = new Backbone.Collection

    sinon.stub Coreon.Lib.ConceptMap, 'LeftToRight', =>
       @leftToRight =
         resize: sinon.spy()
         render: => @leftToRight

    sinon.stub Coreon.Lib.ConceptMap, 'TopDown', =>
      @topDown =
        resize: sinon.spy()
        render: => @topDown

    panel = new Backbone.Model
      width: 320
      height: 230

    view = new Coreon.Views.Panels.ConceptMapPanel
      model: nodes
      hits: hits
      panel: panel

  afterEach ->
    Coreon.application = null
    I18n.t.restore()
    Coreon.Lib.ConceptMap.LeftToRight.restore()
    Coreon.Lib.ConceptMap.TopDown.restore()

  it 'is a panel view', ->
    expect(view).to.be.an.instanceOf Coreon.Views.Panels.PanelView

  it 'creates container', ->
    view.$el.should.have.id 'coreon-concept-map'

  it 'can loop animation', ->
    view.map.startLoop.should.equal Coreon.Modules.Loop.startLoop
    view.map.stopLoop.should.equal Coreon.Modules.Loop.stopLoop

  describe '#initialize()', ->

    it 'calls super implementation', ->
      sinon.spy Coreon.Views.Panels.PanelView::, 'initialize'
      try
        panel = new Backbone.Model
        view.initialize
          model: nodes
          hits: hits
          panel: panel
        original = Coreon.Views.Panels.PanelView::initialize
        # FOLLOWING RAISES ERROR IN NODE.JS:
        #
        # expect(original).to.have.been.calledOnce
        # expect(original).to.have.been.calledWith
        #   model: nodes
        #   hits: hits
        #   panel: panel
        #
        # SO IT IS REPLACED BY:
        expect(original.callCount).to.equal 1
        expect(original.firstCall.args[0]).to.eql
          model: nodes
          hits: hits
          panel: panel
      finally
        Coreon.Views.Panels.PanelView::initialize.restore()

    it 'assigns hits', ->
      hits = new Backbone.Collection
      view.initialize hits: hits, panel: panel
      expect( view ).to.have.property 'hits', hits

    context 'rendering markup skeleton', ->

      it 'renders titlebar', ->
        I18n.t.withArgs('panels.concept_map.title').returns 'Concept Map'
        view.initialize hits: view.hits, panel: panel
        title = view.$( '.titlebar h3' )
        expect( title ).to.exist
        expect( title ).to.have.text 'Concept Map'

      it 'renders titlebar only once', ->
        view.initialize hits: view.hits, panel: panel
        view.initialize hits: view.hits, panel: panel
        view.$('.titlebar').size().should.equal 1

      it 'renders zoom buttons', ->
        I18n.t.withArgs('panels.concept_map.zoom_in').returns 'Zoom in'
        I18n.t.withArgs('panels.concept_map.zoom_out').returns 'Zoom out'
        view.initialize hits: view.hits, panel: panel
        view.$el.should.have '.zoom-in'
        view.$('.zoom-in').should.have.text 'Zoom in'
        view.$('.zoom-in').should.have.attr 'title', 'Zoom in'
        view.$('.zoom-out').should.have.text 'Zoom out'
        view.$('.zoom-out').should.have.attr 'title', 'Zoom out'

      it 'renders toggle button', ->
        I18n.t.withArgs('panels.concept_map.toggle_orientation').returns 'Toggle orientation'
        view.initialize hits: view.hits, panel: panel
        view.$el.should.have '.toggle-orientation'
        view.$('.toggle-orientation').should.have.text 'Toggle orientation'
        view.$('.toggle-orientation').should.have.attr 'title', 'Toggle orientation'
        view.$('.toggle-orientation').should.have.attr 'href', 'javascript:void(0)'

  describe '#render()', ->

    beforeEach ->
      sinon.spy view.model, 'build'
      deferred = null
      view.update = sinon.spy ->
        deferred = $.Deferred()
        deferred.promise()
      @updated = (nodes) =>
        deferred.resolveWith view, [nodes]
      view.centerSelection = sinon.spy()

    it 'can be chained', ->
      view.render().should.equal view

    it 'is triggered on hits update', ->
      view.render = sinon.spy()
      view.initialize hits: view.hits, panel: panel
      view.hits.trigger 'update'
      view.render.should.have.been.calledOnce

    it 'sets rendering status to on', ->
      view.render()
      expect( view ).to.have.property 'rendering', on

    it 'sets rendering status to off when finished', ->
      view.render()
      @deferred.resolve()
      @updated()
      @deferred.resolve()
      @updated()
      expect( view ).to.have.property 'rendering', off

    context 'clear', ->

      it 'resets map', ->
        view.render()
        expect( view.model.build ).to.have.been.calledOnce
        expect( view.model.build ).to.have.been.calledWith []

      it 'defers update and center', ->
        view.render()
        expect( view.update ).to.not.have.been.called
        expect( view.centerSelection ).to.not.have.been.called

      it 'marks placeholder as busy', ->
        view.render()
        @deferred.resolve()
        placeholder = view.model.at(1)
        expect( placeholder.get 'busy' ).to.be.true

      it 'updates when cleared', ->
        view.render()
        @deferred.resolve()
        expect( view.update ).to.have.been.calledOnce

      it 'defers centering selection', ->
        view.render()
        @deferred.resolve()
        expect( view.centerSelection ).to.not.have.been.called

      it 'centers selection when updated', ->
        view.render()
        @deferred.resolve()
        @updated()
        expect( view.centerSelection ).to.have.been.calledOnce
        expect( view.centerSelection.thisValues[0] ).to.equal view
        expect( view.centerSelection.firstCall.args[0] ).to.be.undefined

      it 'builds up map from hits', ->
        concept1 = new Backbone.Model
        concept2 = new Backbone.Model
        view.hits.reset [
          { result: concept1 }
          { result: concept2 }
        ], silent: yes
        view.render()
        view.model.build.reset()
        @deferred.resolve()
        expect( view.model.build ).to.have.been.calledOnce
        expect( view.model.build ).to.have.been.calledWith [ concept1, concept2 ]

      it 'updates map when loaded', ->
        view.render()
        @deferred.resolve()
        view.update.reset()
        view.centerSelection.reset()
        @deferred.resolve()
        expect( view.update ).to.have.been.calledOnce

      it 'defers centering select after reset update', ->
        view.render()
        @deferred.resolve()
        view.update.reset()
        view.centerSelection.reset()
        @deferred.resolve()
        expect( view.centerSelection ).to.not.have.been.called

      it 'centers selection when updated', ->
        concepts = []
        view.render()
        @deferred.resolve()
        view.update.reset()
        @updated()
        view.centerSelection.reset()
        @deferred.resolve()
        @updated concepts
        expect(view.centerSelection).to.have.been.calledOnce
        expect(view.centerSelection).to.have.been.calledWith concepts, animate: yes

  describe '#centerSelection()', ->

    center = null
    translate = null
    pan = null

    nodes = null

    beforeEach ->
      center = sinon.stub()
      center.returns x: 90, y: 30
      view.renderStrategy.center = center

      translate = sinon.spy()
      view.navigator.translate = translate

      pan = sinon.spy()
      view._panAndZoom = pan

      nodes = []

    it 'delegates center calculation to render strategy', ->
      view.centerSelection nodes
      expect(center).to.have.been.calledOnce

    it 'applies padding and scaling to viewport before passing it to strategy', ->
      panel.set 'widget', off, silent: yes
      view.navigator.scale = -> 0.5
      view.padding = -> 20
      view.$el.width 600
      view.$el.height 420
      view.centerSelection nodes
      expect(center).to.have.been.calledWith
        width: 1160
        height: 800

    it 'passes descending list of hits to strategy', ->
      data = [
        {id: "123", hit: no , score: 0}
        {id: "456", hit: yes, score: 1.234}
        {id: "789", hit: yes, score: 4.567}
      ]
      nodes =
        filter: (filter) ->
          filtered = data.filter filter
          sort: (sorter) ->
            filtered.sort sorter
      view.centerSelection nodes
      list = center.firstCall.args[1]
      ids = _(list).pluck 'id'
      expect(ids).to.eql ['789', '456']

    it 'updates navigator with padding and scaling applied', ->
      center.returns
        x: 100
        y: 200
      view.padding = -> 25
      view.navigator.scale = -> 2
      view.centerSelection nodes
      expect(translate).to.have.been.calledOnce
      expect(translate).to.have.been.calledWith [225, 425]

    it 'applies transformation to map', ->
      view.centerSelection nodes, animate: on
      expect(pan).to.have.been.calledOnce
      expect(pan).to.have.been.calledAfter translate
      expect(pan).to.have.been.calledWith animate: on

  describe '#update()', ->

    beforeEach ->
      deferred = $.Deferred()
      view.renderStrategy.render = ->
        deferred.promise()
      @rendered = ->
        deferred.resolve()

    it 'is triggered on placeholder updates', ->
      view.update = sinon.spy()
      view.initialize hits: view.hits, panel: panel
      view.model.trigger 'placeholder:update'
      expect( view.update ).to.have.been.calledOnce

    it 'delegates rendering to strategy', ->
      graph = root: {id: 'root'}, edges: []
      view.model.graph = -> graph
      strategy = view.renderStrategy
      sinon.spy strategy, 'render'
      view.renderStrategy = strategy
      view.update()
      strategy.render.should.have.been.calledWith graph

    it 'updates rendered state of models', ->
      model1 = new Backbone.Model
      model2 = new Backbone.Model
      view.model.add [model1, model2], silent: yes
      view.update()
      expect( model1.get 'rendered' ).to.be.true
      expect( model2.get 'rendered' ).to.be.true

    it 'defers promise', ->
      done = sinon.spy()
      view.renderStrategy.render = ->
        done: (done) ->
      view.update().done done
      expect( done ).to.not.have.been.called

    it 'resolves promise when finished', ->
      done = sinon.spy()
      nodes = []
      edges = []
      view.renderStrategy.render = ->
        done: (callback) -> callback nodes, edges
      view.update(nodes, edges).done done
      expect( done ).to.have.been.calledOnce
      expect( done.thisValues[0] ).to.equal view
      expect( done ).to.have.been.calledWith nodes, edges

  describe '#scheduleForUpdate()', ->

    beforeEach ->
      callbacks = []
      sinon.stub _, 'defer', (callback) =>
        callbacks.push callback
      @next = ->
        callback() for callback in callbacks
        callbacks = []
      view.update = sinon.spy()
      @model = new Backbone.Model rendered: yes

    afterEach ->
      _.defer.restore()

    it 'is triggered on concept node changes', ->
      view.scheduleForUpdate = sinon.spy()
      view.initialize hits: view.hits, panel: panel
      view.model.trigger "change", @model
      expect( view.scheduleForUpdate ).to.have.been.calledOnce
      expect( view.scheduleForUpdate ).to.have.been.calledWith @model

    it 'does not update immediately', ->
      view.scheduleForUpdate @model
      expect( view.update ).to.not.have.been.called

    it 'defers update', ->
      view.scheduleForUpdate @model
      @next()
      expect( view.update ).to.have.been.calledOnce
      expect( view.update.thisValues[0] ).to.equal view

    it 'combines multiple calls to a single update', ->
      view.scheduleForUpdate @model
      view.scheduleForUpdate @model
      @next()
      expect( view.update ).to.have.been.calledOnce

    it 'schedules next update after current', ->
      view.scheduleForUpdate @model
      @next()
      view.update.reset()
      view.scheduleForUpdate @model
      @next()
      expect( view.update ).to.have.been.calledOnce

    it 'skips update for models that are not yet rendered', ->
      @model.set 'rendered', no, silent: yes
      view.scheduleForUpdate @model
      @next()
      expect( view.update ).to.not.have.been.called

    it 'skips updates while rendering', ->
      view.rendering = on
      view.scheduleForUpdate @model
      @next()
      expect( view.update ).to.not.have.been.called

  describe '#expand()', ->

    beforeEach ->
      @model = new Backbone.Model id: '+[86f14a]'
      view.model.add @model
      @placeholder = $ '<g class="concept-node placeholder"></g>'
      d3.select(@placeholder[0]).datum
        id: '+[86f14a]'
        parent:
          id: '86f14a'
      view.$('.concept-map').append @placeholder
      @event = $.Event 'click'
      @event.target = @placeholder[0]
      @deferred = $.Deferred()
      view.update = sinon.spy()
      view.model.expand = sinon.stub().returns @deferred.promise()

    it 'is triggered by click on placeholder', ->
      view.expand = sinon.spy()
      view.delegateEvents()
      @placeholder.trigger @event
      expect( view.expand.callCount ).to.equal 1
      expect( view.expand.firstCall.args[0] ).to.equal @event
      expect( view.expand.thisValues[0] ).to.equal view

    it 'is not triggered when placeholder is busy', ->
      view.expand = sinon.spy()
      view.delegateEvents()
      @placeholder.addClass 'busy'
      @placeholder.trigger @event
      expect( view.expand.callCount ).to.equal 0

    it 'marks placeholder as busy', ->
      view.expand @event
      expect( @model.get 'busy' ).to.be.true

    it 'expands parent node', ->
      view.expand @event
      expect( view.model.expand ).to.have.been.calledOnce
      expect( view.model.expand ).to.have.been.calledWith '86f14a'

    it 'updates view to render progress indicator', ->
      set = sinon.spy()
      @model.set = set
      view.expand @event
      expect( view.update ).to.have.been.calledOnce
      expect( set ).to.have.been.calledOnce
      expect( set ).to.have.been.calledWith 'busy', on
      expect( view.update ).to.have.been.calledAfter set

    it 'sets rendering status to on', ->
      view.expand @event
      expect( view ).to.have.property 'rendering', on

    context 'done', ->

      it 'sets rendering status to off when finished', ->
        view.expand @event
        @deferred.resolve()
        expect( view ).to.have.property 'rendering', off

      it 'updates after model finished expanding', ->
        view.expand @event
        view.update.reset()
        @deferred.resolve()
        expect( view.update ).to.have.been.calledOnce

      it 'resets busy state to idle before updating', ->
        sinon.spy @model, 'set'
        view.expand @event
        view.update.reset()
        @deferred.resolve()
        expect( @model.get 'busy' ).to.be.false
        expect( @model.set ).to.have.been.calledBefore view.update

    context 'fail', ->

      it 'updates map', ->
        view.expand @event
        view.update.reset()
        @deferred.reject()
        expect( view.update ).to.have.been.calledOnce

      it 'resets busy state to idle before updating', ->
        sinon.spy @model, 'set'
        view.expand @event
        view.update.reset()
        @deferred.reject()
        expect( @model.get 'busy' ).to.be.false
        expect( @model.set ).to.have.been.calledBefore view.update

  describe '#zoomIn()', ->

    beforeEach ->
      view.renderStrategy.render = ->
        done: ->

    it 'is triggered by click on button', ->
      view.zoomIn = sinon.spy()
      view.delegateEvents()
      view.$('.zoom-in').click()
      view.zoomIn.should.have.been.calledOnce

    it 'increments zoom factor', ->
      view.options.scaleStep = 0.5
      view.navigator.scale(1)
      view.zoomIn()
      view.navigator.scale().should.equal 1.5

    it 'does not extent max scale factor', ->
      view.options.scaleExtent = [0.5, 3]
      view.options.scaleStep = 0.5
      view.navigator.scale(2.7)
      view.zoomIn()
      view.navigator.scale().should.equal 3

    it 'applies zoom', ->
      view.navigator.scale(1)
      view.options.scaleStep = 0.5
      view.update()
      view.zoomIn()
      view.$('.concept-map').attr('transform').should.contain 'scale(1.5)'

  describe '#zoomOut()', ->

    beforeEach ->
      view.renderStrategy.render = ->
        done: ->

    it 'is triggered by click on button', ->
      view.zoomOut = sinon.spy()
      view.delegateEvents()
      view.$('.zoom-out').click()
      view.zoomOut.should.have.been.calledOnce

    it 'outcrements zoom factor', ->
      view.options.scaleStep = 0.5
      view.navigator.scale(1.7)
      view.zoomOut()
      view.navigator.scale().should.equal 1.2

    it 'does not extent min scale factor', ->
      view.options.scaleExtent = [0.5, 3]
      view.options.scaleStep = 0.5
      view.navigator.scale(0.7)
      view.zoomOut()
      view.navigator.scale().should.equal 0.5

    it 'applies zoom', ->
      view.navigator.scale(1)
      view.options.scaleStep = 0.5
      view.update()
      view.zoomIn()
      view.$('.concept-map').attr('transform').should.contain 'scale(1.5)'

  describe '#resize()', ->

    it 'calls super implementation', ->
      sinon.spy Coreon.Views.Panels.PanelView::, 'resize'
      try
        view.resize()
        original = Coreon.Views.Panels.PanelView::resize
        # FOLLOWING RAISES ERROR IN NODE.JS:
        #
        # expect(original).to.have.been.calledOnce
        # expect(original).to.have.been.calledOn view
        #
        # SO IT IS REPLACED BY:
        expect(original.callCount).to.equal 1
        expect(original.firstCall.thisValue).to.equal view
      finally
        Coreon.Views.Panels.PanelView::resize.restore()

    it 'adjusts svg dimensions', ->
      view.dimensions = ->
        width: 300
        height: 200
      view.resize()
      svg = view.$('svg')
      expect(svg).to.have.attr 'width', '300px'
      expect(svg).to.have.attr 'height', '200px'

    it 'resizes render strategy', ->
      view.dimensions = ->
        width: 300
        height: 200
      resize = view.renderStrategy.resize
      resize.reset()
      view.resize()
      expect(resize).to.have.been.calledOnce
      expect(resize).to.have.been.calledWith 300, 200

  describe '#toggleOrientation()', ->

    beforeEach ->
      view.map = d3.select $('<svg>')[0]

    it 'is triggered by click on toggle', ->
      view.toggleOrientation = sinon.spy()
      view.delegateEvents()
      view.$('.toggle-orientation').click()
      view.toggleOrientation.should.have.been.calledOnce

    it 'switches render strategy', ->
      Coreon.Lib.ConceptMap.LeftToRight.reset()
      Coreon.Lib.ConceptMap.TopDown.reset()
      view.toggleOrientation()
      Coreon.Lib.ConceptMap.TopDown.should.not.have.been.called
      Coreon.Lib.ConceptMap.LeftToRight.should.have.been.calledOnce
      Coreon.Lib.ConceptMap.LeftToRight.should.have.been.calledWithNew
      Coreon.Lib.ConceptMap.LeftToRight.should.have.been.calledWith view.map
      view.renderStrategy.should.equal @leftToRight

    it 'toggles between render strategies', ->
      view.toggleOrientation()
      Coreon.Lib.ConceptMap.LeftToRight.reset()
      Coreon.Lib.ConceptMap.TopDown.reset()
      view.toggleOrientation()
      Coreon.Lib.ConceptMap.LeftToRight.should.not.have.been.called
      Coreon.Lib.ConceptMap.TopDown.should.have.been.calledOnce
      Coreon.Lib.ConceptMap.TopDown.should.have.been.calledWithNew
      Coreon.Lib.ConceptMap.TopDown.should.have.been.calledWith view.map
      view.renderStrategy.should.equal @topDown

    it 'renders view', ->
      view.render = sinon.spy()
      view.toggleOrientation()
      view.render.should.have.been.calledOnce

  describe '#_panAndZoom()', ->

    beforeEach ->
      view.navigator.translate [12, 345]
      view.navigator.scale 1.5

    context 'animated', ->

      it 'applies transition', ->
        transition = d3.transition()
        transition.attr = sinon.spy()
        view.map.transition = sinon.stub().returns transition
        view._panAndZoom animate: yes
        expect( transition.attr ).to.have.been.calledOnce
        expect( transition.attr ).to.have.been.calledWith 'transform',
          'translate(12,345) scale(1.5)'
