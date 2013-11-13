#= require spec_helper
#= require views/widgets/concept_map_view

describe 'Coreon.Views.Widgets.ConceptMapView', ->

  before ->
    unless window.requestAnimationFrame?
      @no_rAF = yes
      window.requestAnimationFrame = ->
      window.cancelAnimationFrame = ->

  after ->
    if @no_rAF
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

    sinon.stub Coreon.Views.Widgets.ConceptMap, 'LeftToRight', =>
       @leftToRight =
         resize: sinon.spy()
         render: => @leftToRight

    sinon.stub Coreon.Views.Widgets.ConceptMap, 'TopDown', =>
      @topDown =
        resize: sinon.spy()
        render: => @topDown

    @view = new Coreon.Views.Widgets.ConceptMapView
      model: nodes
      hits: hits

  afterEach ->
    Coreon.application = null
    I18n.t.restore()
    Coreon.Views.Widgets.ConceptMap.LeftToRight.restore()
    Coreon.Views.Widgets.ConceptMap.TopDown.restore()

  it 'is a Backbone view', ->
    @view.should.be.an.instanceof Backbone.View

  it 'creates container', ->
    @view.$el.should.have.id 'coreon-concept-map'
    @view.$el.should.have.class 'widget'

  it 'can loop animation', ->
    @view.map.startLoop.should.equal Coreon.Modules.Loop.startLoop
    @view.map.stopLoop.should.equal Coreon.Modules.Loop.stopLoop

  describe '#initialize()', ->

    it 'assigns hits', ->
      hits = new Backbone.Collection
      @view.initialize hits: hits
      expect( @view ).to.have.property 'hits', hits

    context 'rendering markup skeleton', ->

      it 'renders titlebar', ->
        I18n.t.withArgs('concept-map.title').returns 'Concept Map'
        @view.initialize hits: @view.hits
        @view.$el.should.have '.titlebar h4'
        @view.$('.titlebar h4').should.have.text 'Concept Map'

      it 'renders titlebar only once', ->
        @view.initialize hits: @view.hits
        @view.initialize hits: @view.hits
        @view.$('.titlebar').size().should.equal 1

      it 'renders zoom buttons', ->
        I18n.t.withArgs('concept-map.zoom-in').returns 'Zoom in'
        I18n.t.withArgs('concept-map.zoom-out').returns 'Zoom out'
        @view.initialize hits: @view.hits
        @view.$el.should.have '.zoom-in'
        @view.$('.zoom-in').should.have.text 'Zoom in'
        @view.$('.zoom-in').should.have.attr 'title', 'Zoom in'
        @view.$('.zoom-out').should.have.text 'Zoom out'
        @view.$('.zoom-out').should.have.attr 'title', 'Zoom out'

      it 'renders toggle button', ->
        I18n.t.withArgs('concept-map.toggle-orientation').returns 'Toggle orientation'
        @view.initialize hits: @view.hits
        @view.$el.should.have '.toggle-orientation'
        @view.$('.toggle-orientation').should.have.text 'Toggle orientation'
        @view.$('.toggle-orientation').should.have.attr 'title', 'Toggle orientation'

      it 'creates resize handle', ->
        @view.initialize hits: @view.hits
        @view.$el.should.have '.ui-resizable-s'

    # context 'restoring from session', ->

    #   beforeEach ->
    #     sinon.stub(localStorage, 'getItem').returns JSON.stringify
    #       conceptMap:
    #         width: 347
    #         height: 456

    #   afterEach ->
    #     localStorage.getItem.restore()

    #   it 'restores dimensions', ->
    #     @view.resize = sinon.spy()
    #     @view.initialize hits: @view.hits
    #     @view.resize.should.have.been.calledOnce
    #     @view.resize.should.have.been.calledWith 347, 456

  describe '#render()', ->

    beforeEach ->
      sinon.spy @view.model, 'build'
      deferred = $.Deferred()
      @view.update = sinon.stub().returns deferred.promise()
      @updated = -> deferred.resolveWith @view
      @view.centerSelection = sinon.spy()

    it 'can be chained', ->
      @view.render().should.equal @view

    it 'is triggered on hits update', ->
      @view.render = sinon.spy()
      @view.initialize hits: @view.hits
      @view.hits.trigger 'update'
      @view.render.should.have.been.calledOnce

    it 'sets rendering status to on', ->
      @view.render()
      expect( @view ).to.have.property 'rendering', on

    it 'sets rendering status to off when finished', ->
      @view.render()
      @deferred.resolve()
      @updated()
      @deferred.resolve()
      @updated()
      expect( @view ).to.have.property 'rendering', off

    context 'clear', ->

      it 'resets map', ->
        @view.render()
        expect( @view.model.build ).to.have.been.calledOnce
        expect( @view.model.build ).to.have.been.calledWith []

      it 'defers update and center', ->
        @view.render()
        expect( @view.update ).to.not.have.been.called
        expect( @view.centerSelection ).to.not.have.been.called

      it 'marks placeholder as busy', ->
        @view.render()
        @deferred.resolve()
        placeholder = @view.model.at(1)
        expect( placeholder.get 'busy' ).to.be.true

      it 'updates when cleared', ->
        @view.render()
        @deferred.resolve()
        expect( @view.update ).to.have.been.calledOnce

      it 'defers centering selection', ->
        @view.render()
        @deferred.resolve()
        expect( @view.centerSelection ).to.not.have.been.called

      it 'centers selection when updated', ->
        @view.render()
        @deferred.resolve()
        @updated()
        expect( @view.centerSelection ).to.have.been.calledOnce
        expect( @view.centerSelection.thisValues[0] ).to.equal @view

      it 'builds up map from hits', ->
        concept1 = new Backbone.Model
        concept2 = new Backbone.Model
        @view.hits.reset [
          { result: concept1 }
          { result: concept2 }
        ], silent: yes
        @view.render()
        @view.model.build.reset()
        @deferred.resolve()
        expect( @view.model.build ).to.have.been.calledOnce
        expect( @view.model.build ).to.have.been.calledWith [ concept1, concept2 ]

      it 'updates map when loaded', ->
        @view.render()
        @deferred.resolve()
        @view.update.reset()
        @view.centerSelection.reset()
        @deferred.resolve()
        expect( @view.update ).to.have.been.calledOnce

      it 'defers centering select after reset update', ->
        @view.render()
        @deferred.resolve()
        @view.update.reset()
        @view.centerSelection.reset()
        @deferred.resolve()
        expect( @view.centerSelection ).to.not.have.been.called

      it 'centers selection when updated', ->
        @view.render()
        @deferred.resolve()
        @view.update.reset()
        @updated()
        @view.centerSelection.reset()
        @deferred.resolve()
        @updated()
        expect( @view.centerSelection ).to.have.been.calledOnce

  describe '#centerSelection()', ->

    beforeEach ->
      center = sinon.stub().returns x: 90, y: 30
      @view.renderStrategy.center = center
      @view.navigator.translate = sinon.spy()
      @view._panAndZoom = sinon.spy()
      @nodes = []

    it 'delegates center calculation to render strategy', ->
      @view.width     = 300
      @view.svgHeight = 200
      @view.padding = -> 20
      @view.centerSelection @nodes
      center = @view.renderStrategy.center
      expect( center ).to.have.been.calledOnce
      expect( center ).to.have.been.calledWith { width: 300 - 2 * 20, height: 200 - 2 * 20 }

    it 'passes hits to render strategy', ->
      data = [
        { id: "123", hit: no , score: 0 }
        { id: "456", hit: yes, score: 1.234 }
        { id: "789", hit: yes, score: 4.567 }
      ]
      nodes = filter: (filter) ->
        filtered = data.filter filter
        sort: (sorter) ->
          filtered.sort sorter
      @view.centerSelection nodes
      center = @view.renderStrategy.center
      expect( center.firstCall.args[1] ).to.have.lengthOf 2
      expect( center.firstCall.args[1][0] ).to.have.property 'id', '789'
      expect( center.firstCall.args[1][1] ).to.have.property 'id', '456'

    it 'applies offset with padding to map', ->
      @view.renderStrategy.center.returns
        x: 110
        y: 45
      @view.padding = -> 20
      @view.centerSelection @nodes
      translate = @view.navigator.translate
      expect( translate ).to.have.been.calledOnce
      expect( translate ).to.have.been.calledWith [110 + 20, 45 + 20]
      pan = @view._panAndZoom
      expect( pan ).to.have.been.calledOnce
      expect( pan ).to.have.been.calledAfter translate

  describe '#update()', ->

    beforeEach ->
      deferred = $.Deferred()
      @view.renderStrategy = render: ->
        deferred.promise()
      @rendered = ->
        deferred.resolve()

    it 'is triggered on placeholder updates', ->
      @view.update = sinon.spy()
      @view.initialize hits: @view.hits
      @view.model.trigger 'placeholder:update'
      expect( @view.update ).to.have.been.calledOnce

    it 'delegates rendering to strategy', ->
      graph = root: {id: 'root'}, edges: []
      @view.model.graph = -> graph
      strategy = @view.renderStrategy
      sinon.spy strategy, 'render'
      @view.renderStrategy = strategy
      @view.update()
      strategy.render.should.have.been.calledWith graph

    it 'updates rendered state of models', ->
      model1 = new Backbone.Model
      model2 = new Backbone.Model
      @view.model.add [model1, model2], silent: yes
      @view.update()
      expect( model1.get 'rendered' ).to.be.true
      expect( model2.get 'rendered' ).to.be.true

    it 'defers promise', ->
      done = sinon.spy()
      @view.renderStrategy = render: ->
        done: (done) ->
      @view.update().done done
      expect( done ).to.not.have.been.called

    it 'resolves promise when finished', ->
      done = sinon.spy()
      nodes = []
      edges = []
      @view.renderStrategy = render: ->
        done: (callback) -> callback nodes, edges
      @view.update(nodes, edges).done done
      expect( done ).to.have.been.calledOnce
      expect( done.thisValues[0] ).to.equal @view
      expect( done ).to.have.been.calledWith nodes, edges

  describe '#scheduleForUpdate()', ->

    beforeEach ->
      callbacks = []
      sinon.stub _, 'defer', (callback) =>
        callbacks.push callback
      @next = ->
        callback() for callback in callbacks
        callbacks = []
      @view.update = sinon.spy()
      @model = new Backbone.Model rendered: yes

    afterEach ->
      _.defer.restore()

    it 'is triggered on concept node changes', ->
      @view.scheduleForUpdate = sinon.spy()
      @view.initialize hits: @view.hits
      @view.model.trigger "change", @model
      expect( @view.scheduleForUpdate ).to.have.been.calledOnce
      expect( @view.scheduleForUpdate ).to.have.been.calledWith @model

    it 'does not update immediately', ->
      @view.scheduleForUpdate @model
      expect( @view.update ).to.not.have.been.called

    it 'defers update', ->
      @view.scheduleForUpdate @model
      @next()
      expect( @view.update ).to.have.been.calledOnce
      expect( @view.update.thisValues[0] ).to.equal @view

    it 'combines multiple calls to a single update', ->
      @view.scheduleForUpdate @model
      @view.scheduleForUpdate @model
      @next()
      expect( @view.update ).to.have.been.calledOnce

    it 'schedules next update after current', ->
      @view.scheduleForUpdate @model
      @next()
      @view.update.reset()
      @view.scheduleForUpdate @model
      @next()
      expect( @view.update ).to.have.been.calledOnce

    it 'skips update for models that are not yet rendered', ->
      @model.set 'rendered', no, silent: yes
      @view.scheduleForUpdate @model
      @next()
      expect( @view.update ).to.not.have.been.called

    it 'skips updates while rendering', ->
      @view.rendering = on
      @view.scheduleForUpdate @model
      @next()
      expect( @view.update ).to.not.have.been.called

  describe '#expand()', ->

    beforeEach ->
      @model = new Backbone.Model id: '+[86f14a]'
      @view.model.add @model
      @placeholder = $ '<g class="concept-node placeholder"></g>'
      d3.select(@placeholder[0]).datum
        id: '+[86f14a]'
        parent:
          id: '86f14a'
      @view.$('.concept-map').append @placeholder
      @event = $.Event 'click'
      @event.target = @placeholder[0]
      @deferred = $.Deferred()
      @view.update = sinon.spy()
      @view.model.expand = sinon.stub().returns @deferred.promise()

    it 'is triggered by click on placeholder', ->
      @view.expand = sinon.spy()
      @view.delegateEvents()
      @placeholder.trigger @event
      expect( @view.expand.callCount ).to.equal 1
      expect( @view.expand.firstCall.args[0] ).to.equal @event
      expect( @view.expand.thisValues[0] ).to.equal @view

    it 'is not triggered when placeholder is busy', ->
      @view.expand = sinon.spy()
      @view.delegateEvents()
      @placeholder.addClass 'busy'
      @placeholder.trigger @event
      expect( @view.expand.callCount ).to.equal 0

    it 'marks placeholder as busy', ->
      @view.expand @event
      expect( @model.get 'busy' ).to.be.true

    it 'expands parent node', ->
      @view.expand @event
      expect( @view.model.expand ).to.have.been.calledOnce
      expect( @view.model.expand ).to.have.been.calledWith '86f14a'

    it 'updates view to render progress indicator', ->
      set = sinon.spy()
      @model.set = set
      @view.expand @event
      expect( @view.update ).to.have.been.calledOnce
      expect( set ).to.have.been.calledOnce
      expect( set ).to.have.been.calledWith 'busy', on
      expect( @view.update ).to.have.been.calledAfter set

    context 'done', ->

      it 'updates after model finished expanding', ->
        @view.expand @event
        @view.update.reset()
        @deferred.resolve()
        expect( @view.update ).to.have.been.calledOnce

      it 'resets busy state to idle before updating', ->
        sinon.spy @model, 'set'
        @view.expand @event
        @view.update.reset()
        @deferred.resolve()
        expect( @model.get 'busy' ).to.be.false
        expect( @model.set ).to.have.been.calledBefore @view.update

    context 'fail', ->

      it 'updates map', ->
        @view.expand @event
        @view.update.reset()
        @deferred.reject()
        expect( @view.update ).to.have.been.calledOnce

      it 'resets busy state to idle before updating', ->
        sinon.spy @model, 'set'
        @view.expand @event
        @view.update.reset()
        @deferred.reject()
        expect( @model.get 'busy' ).to.be.false
        expect( @model.set ).to.have.been.calledBefore @view.update

  describe '#zoomIn()', ->

    beforeEach ->
      @view.renderStrategy = render: ->
        done: ->

    it 'is triggered by click on button', ->
      @view.zoomIn = sinon.spy()
      @view.delegateEvents()
      @view.$('.zoom-in').click()
      @view.zoomIn.should.have.been.calledOnce

    it 'increments zoom factor', ->
      @view.options.scaleStep = 0.5
      @view.navigator.scale(1)
      @view.zoomIn()
      @view.navigator.scale().should.equal 1.5

    it 'does not extent max scale factor', ->
      @view.options.scaleExtent = [0.5, 3]
      @view.options.scaleStep = 0.5
      @view.navigator.scale(2.7)
      @view.zoomIn()
      @view.navigator.scale().should.equal 3

    it 'applies zoom', ->
      @view.navigator.scale(1)
      @view.options.scaleStep = 0.5
      @view.update()
      @view.zoomIn()
      @view.$('.concept-map').attr('transform').should.contain 'scale(1.5)'

  describe '#zoomOut()', ->

    beforeEach ->
      @view.renderStrategy = render: ->
        done: ->

    it 'is triggered by click on button', ->
      @view.zoomOut = sinon.spy()
      @view.delegateEvents()
      @view.$('.zoom-out').click()
      @view.zoomOut.should.have.been.calledOnce

    it 'outcrements zoom factor', ->
      @view.options.scaleStep = 0.5
      @view.navigator.scale(1.7)
      @view.zoomOut()
      @view.navigator.scale().should.equal 1.2

    it 'does not extent min scale factor', ->
      @view.options.scaleExtent = [0.5, 3]
      @view.options.scaleStep = 0.5
      @view.navigator.scale(0.7)
      @view.zoomOut()
      @view.navigator.scale().should.equal 0.5

    it 'applies zoom', ->
      @view.navigator.scale(1)
      @view.options.scaleStep = 0.5
      @view.update()
      @view.zoomIn()
      @view.$('.concept-map').attr('transform').should.contain 'scale(1.5)'

  # describe '#resize()', ->

  #   beforeEach ->
  #     sinon.stub(localStorage, 'getItem').returns null
  #     sinon.stub localStorage, 'setItem'
  #     @clock = sinon.useFakeTimers()
  #     @view.$el.width 160
  #     @view.$el.height 120
  #     @view.renderStrategy =
  #       render: -> @
  #       resize: sinon.spy()

  #   afterEach ->
  #     localStorage.getItem.restore()
  #     localStorage.setItem.restore()
  #     @clock.restore()

  #   it 'is triggered when resize handle is dragged', ->
  #     $('#konacha').append @view.render().$el
  #     handle = @view.$('.ui-resizable-s')
  #     @view.resize = sinon.spy()
  #     handle.simulate 'mouseover'
  #     handle.simulate 'drag', dy: -24, moves: 1
  #     @view.resize.should.have.been.calledOnce
  #     @view.resize.should.have.been.calledWith null, 96

  #   it 'adjusts el dimensions', ->
  #     @view.resize 67, 116
  #     @view.$el.height().should.equal 116
  #     @view.$el.width().should.equal 67

  #   it 'keeps height when null', ->
  #     @view.resize 67, null
  #     @view.$el.height().should.equal 120
  #     @view.$el.width().should.equal 67

  #   it 'keeps width when null', ->
  #     @view.resize null, 77
  #     @view.$el.height().should.equal 77
  #     @view.$el.width().should.equal 160

  #   it 'adjusts svg dimensions', ->
  #     @view.options.svgOffset = 18
  #     @view.resize 200, 300
  #     svg = @view.$('svg')
  #     svg.should.have.attr 'width', '200px'
  #     svg.should.have.attr 'height', '282px'

  #   it 'resizes render strategy', ->
  #     @view.renderStrategy.resize.reset()
  #     @view.resize 200, 300
  #     @view.renderStrategy.resize.should.have.been.calledOnce

  #   it 'stores dimensions when finished', ->
  #     @view.resize 123, 334
  #     @clock.tick 1000
  #     localStorage.setItem.should.have.been.calledOnce
  #     localStorage.setItem.should.have.been.calledWith 'face42', JSON.stringify
  #       'conceptMap':
  #         width: 123
  #         height: 334

  describe '#toggleOrientation()', ->

    beforeEach ->
      @view.map = d3.select $('<svg>')[0]

    it 'is triggered by click on toggle', ->
      @view.toggleOrientation = sinon.spy()
      @view.delegateEvents()
      @view.$('.toggle-orientation').click()
      @view.toggleOrientation.should.have.been.calledOnce

    it 'switches render strategy', ->
      Coreon.Views.Widgets.ConceptMap.LeftToRight.reset()
      Coreon.Views.Widgets.ConceptMap.TopDown.reset()
      @view.toggleOrientation()
      Coreon.Views.Widgets.ConceptMap.TopDown.should.not.have.been.called
      Coreon.Views.Widgets.ConceptMap.LeftToRight.should.have.been.calledOnce
      Coreon.Views.Widgets.ConceptMap.LeftToRight.should.have.been.calledWithNew
      Coreon.Views.Widgets.ConceptMap.LeftToRight.should.have.been.calledWith @view.map
      @view.renderStrategy.should.equal @leftToRight

    it 'toggles between render strategies', ->
      @view.toggleOrientation()
      Coreon.Views.Widgets.ConceptMap.LeftToRight.reset()
      Coreon.Views.Widgets.ConceptMap.TopDown.reset()
      @view.toggleOrientation()
      Coreon.Views.Widgets.ConceptMap.LeftToRight.should.not.have.been.called
      Coreon.Views.Widgets.ConceptMap.TopDown.should.have.been.calledOnce
      Coreon.Views.Widgets.ConceptMap.TopDown.should.have.been.calledWithNew
      Coreon.Views.Widgets.ConceptMap.TopDown.should.have.been.calledWith @view.map
      @view.renderStrategy.should.equal @topDown

    it 'renders view', ->
      @view.render = sinon.spy()
      @view.toggleOrientation()
      @view.render.should.have.been.calledOnce
