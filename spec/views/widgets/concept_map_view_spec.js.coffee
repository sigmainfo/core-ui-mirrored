#= require spec_helper
#= require views/widgets/concept_map_view

describe "Coreon.Views.Widgets.ConceptMapView", ->

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
    sinon.stub I18n, "t"
    Coreon.application =
      cacheId: -> "face42"

    nodes = new Backbone.Collection
    nodes.tree = ->
      root:
        children: []
      edges: []
    nodes.isCompletelyLoaded = -> true

    sinon.stub Coreon.Views.Widgets.ConceptMap, "LeftToRight", =>
      @leftToRight = 
        resize: sinon.spy()
        render: => @lefttoright

    sinon.stub Coreon.Views.Widgets.ConceptMap, "TopDown", =>
      @topDown =
        resize: sinon.spy()
        render: => @topDown

    @view = new Coreon.Views.Widgets.ConceptMapView
      model: nodes

  afterEach ->
    Coreon.application = null
    I18n.t.restore()
    Coreon.Views.Widgets.ConceptMap.LeftToRight.restore()
    Coreon.Views.Widgets.ConceptMap.TopDown.restore()

  it "is a simple view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates container", ->
    @view.$el.should.have.id "coreon-concept-map"
    @view.$el.should.have.class "widget"

  it "can loop animation", ->
    @view.map.startLoop.should.equal Coreon.Modules.Loop.startLoop
    @view.map.stopLoop.should.equal Coreon.Modules.Loop.stopLoop

  describe "initialize()", ->

    context "rendering markup skeleton", ->

      it "renders titlebar", ->
        I18n.t.withArgs("concept-map.title").returns "Concept Map"
        @view.initialize()
        @view.$el.should.have ".titlebar h4"
        @view.$(".titlebar h4").should.have.text "Concept Map"

      it "renders titlebar only once", ->
        @view.initialize()
        @view.initialize()
        @view.$(".titlebar").size().should.equal 1

      it "renders zoom buttons", ->
        I18n.t.withArgs("concept-map.zoom-in").returns "Zoom in"
        I18n.t.withArgs("concept-map.zoom-out").returns "Zoom out"
        @view.initialize()
        @view.$el.should.have ".zoom-in"
        @view.$(".zoom-in").should.have.text "Zoom in"
        @view.$(".zoom-in").should.have.attr "title", "Zoom in"
        @view.$(".zoom-out").should.have.text "Zoom out"
        @view.$(".zoom-out").should.have.attr "title", "Zoom out"

      it "renders toggle button", ->
        I18n.t.withArgs("concept-map.toggle-orientation").returns "Toggle orientation"
        @view.initialize()
        @view.$el.should.have ".toggle-orientation"
        @view.$(".toggle-orientation").should.have.text "Toggle orientation"
        @view.$(".toggle-orientation").should.have.attr "title", "Toggle orientation"

      it "creates resize handle", ->
        @view.initialize()
        @view.$el.should.have ".ui-resizable-s"

    # context "restoring from session", ->

    #   beforeEach ->
    #     sinon.stub(localStorage, "getItem").returns JSON.stringify
    #       conceptMap:
    #         width: 347
    #         height: 456

    #   afterEach ->
    #     localStorage.getItem.restore()

    #   it "restores dimensions", ->
    #     @view.resize = sinon.spy()
    #     @view.initialize()
    #     @view.resize.should.have.been.calledOnce
    #     @view.resize.should.have.been.calledWith 347, 456

  describe "render()", ->
  
    it "can be chained", ->
      @view.render().should.equal @view

    it "is triggered on collection reset", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "reset"
      @view.render.should.have.been.calledOnce

    it "is triggered on collection load", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "loaded"
      @view.render.should.have.been.calledOnce

    it "updates view", ->
      @view.update = sinon.spy()
      @view.render()
      @view.update.should.have.been.calledOnce

    it "centers Selection", ->
      @view.centerSelection = sinon.spy()
      @view.render()
      @view.centerSelection.should.have.been.calledOnce

  describe "update()", ->

    beforeEach ->
      @view.renderStrategy = render: ->
  
    it "can be chained", ->
      @view.update().should.equal @view

    it "delegates rendering to strategy", ->
      tree = root: {id: "root"}, edges: []
      @view.model.tree = -> tree
      strategy = render: sinon.spy()
      @view.renderStrategy = strategy
      @view.update()
      strategy.render.should.have.been.calledWith tree

    context "triggers", ->

      beforeEach ->
        @view.update = sinon.spy()
        @view.model.loadingTree = no
        @view.render()
        @view.update.reset()

      it "is triggered when node was added", ->
        @view.model.trigger "add"
        @view.update.should.have.been.calledOnce

      it "is triggered when node was removed", ->
        @view.model.trigger "remove"
        @view.update.should.have.been.calledOnce

      it "is triggered on label change", ->
        @view.model.trigger "change:label"
        @view.update.should.have.been.calledOnce

      it "is triggered on hit change", ->
        @view.model.trigger "change:hit"
        @view.update.should.have.been.calledOnce

      it "is never triggered when loading tree", ->
        @view.model.loadingTree = yes
        @view.render()
        @view.update.reset()
        @view.model.trigger "add"
        @view.model.trigger "remove"
        @view.model.trigger "change:label"
        @view.model.trigger "change:hit"
        @view.update.should.not.have.been.called

  describe "zoomIn()", ->

    beforeEach ->
      @view.renderStrategy = render: -> 
  
    it "is triggered by click on button", ->
      @view.zoomIn = sinon.spy()
      @view.delegateEvents()
      @view.$(".zoom-in").click()
      @view.zoomIn.should.have.been.calledOnce

    it "increments zoom factor", ->
      @view.options.scaleStep = 0.5
      @view.navigator.scale(1)
      @view.zoomIn()
      @view.navigator.scale().should.equal 1.5

    it "does not extent max scale factor", ->
      @view.options.scaleExtent = [0.5, 3]
      @view.options.scaleStep = 0.5
      @view.navigator.scale(2.7)
      @view.zoomIn()
      @view.navigator.scale().should.equal 3

    it "applies zoom", ->
      @view.navigator.scale(1)
      @view.options.scaleStep = 0.5
      @view.update()
      @view.zoomIn()
      @view.$(".concept-map").attr("transform").should.contain "scale(1.5)"
      
  describe "zoomOut()", ->

    beforeEach ->
      @view.renderStrategy = render: ->
  
    it "is triggered by click on button", ->
      @view.zoomOut = sinon.spy()
      @view.delegateEvents()
      @view.$(".zoom-out").click()
      @view.zoomOut.should.have.been.calledOnce

    it "outcrements zoom factor", ->
      @view.options.scaleStep = 0.5
      @view.navigator.scale(1.7)
      @view.zoomOut()
      @view.navigator.scale().should.equal 1.2

    it "does not extent min scale factor", ->
      @view.options.scaleExtent = [0.5, 3]
      @view.options.scaleStep = 0.5
      @view.navigator.scale(0.7)
      @view.zoomOut()
      @view.navigator.scale().should.equal 0.5

    it "applies zoom", ->
      @view.navigator.scale(1)
      @view.options.scaleStep = 0.5
      @view.update()
      @view.zoomIn()
      @view.$(".concept-map").attr("transform").should.contain "scale(1.5)"

  # describe "resize()", ->

  #   beforeEach ->
  #     sinon.stub(localStorage, "getItem").returns null
  #     sinon.stub localStorage, "setItem"
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

  #   it "is triggered when resize handle is dragged", ->
  #     $("#konacha").append @view.render().$el
  #     handle = @view.$(".ui-resizable-s")
  #     @view.resize = sinon.spy()
  #     handle.simulate "mouseover"
  #     handle.simulate "drag", dy: -24, moves: 1
  #     @view.resize.should.have.been.calledOnce
  #     @view.resize.should.have.been.calledWith null, 96

  #   it "adjusts el dimensions", ->
  #     @view.resize 67, 116
  #     @view.$el.height().should.equal 116
  #     @view.$el.width().should.equal 67

  #   it "keeps height when null", ->
  #     @view.resize 67, null
  #     @view.$el.height().should.equal 120
  #     @view.$el.width().should.equal 67

  #   it "keeps width when null", ->
  #     @view.resize null, 77
  #     @view.$el.height().should.equal 77
  #     @view.$el.width().should.equal 160

  #   it "adjusts svg dimensions", ->
  #     @view.options.svgOffset = 18
  #     @view.resize 200, 300
  #     svg = @view.$("svg")
  #     svg.should.have.attr "width", "200px"
  #     svg.should.have.attr "height", "282px"

  #   it "resizes render strategy", ->
  #     @view.renderStrategy.resize.reset()
  #     @view.resize 200, 300
  #     @view.renderStrategy.resize.should.have.been.calledOnce

  #   it "stores dimensions when finished", ->
  #     @view.resize 123, 334
  #     @clock.tick 1000
  #     localStorage.setItem.should.have.been.calledOnce
  #     localStorage.setItem.should.have.been.calledWith "face42", JSON.stringify
  #       "conceptMap":
  #         width: 123
  #         height: 334

  describe "toggleOrientation()", ->

    beforeEach ->
      @view.map = d3.select $("<svg>")[0]

    it "is triggered by click on toggle", ->
      @view.toggleOrientation = sinon.spy()
      @view.delegateEvents()
      @view.$(".toggle-orientation").click()
      @view.toggleOrientation.should.have.been.calledOnce

    it "switches render strategy", ->
      Coreon.Views.Widgets.ConceptMap.LeftToRight.reset()
      Coreon.Views.Widgets.ConceptMap.TopDown.reset()
      @view.toggleOrientation()
      Coreon.Views.Widgets.ConceptMap.TopDown.should.not.have.been.called
      Coreon.Views.Widgets.ConceptMap.LeftToRight.should.have.been.calledOnce
      Coreon.Views.Widgets.ConceptMap.LeftToRight.should.have.been.calledWithNew
      Coreon.Views.Widgets.ConceptMap.LeftToRight.should.have.been.calledWith @view.map
      @view.renderStrategy.should.equal @leftToRight
      
    it "toggles between render strategies", ->
      @view.toggleOrientation()
      Coreon.Views.Widgets.ConceptMap.LeftToRight.reset()
      Coreon.Views.Widgets.ConceptMap.TopDown.reset()
      @view.toggleOrientation()
      Coreon.Views.Widgets.ConceptMap.LeftToRight.should.not.have.been.called
      Coreon.Views.Widgets.ConceptMap.TopDown.should.have.been.calledOnce
      Coreon.Views.Widgets.ConceptMap.TopDown.should.have.been.calledWithNew
      Coreon.Views.Widgets.ConceptMap.TopDown.should.have.been.calledWith @view.map
      @view.renderStrategy.should.equal @topDown

    it "renders view", ->
      @view.render = sinon.spy()
      @view.toggleOrientation()
      @view.render.should.have.been.calledOnce 
