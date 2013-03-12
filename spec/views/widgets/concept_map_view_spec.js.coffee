#= require spec_helper
#= require views/widgets/concept_map_view

describe "Coreon.Views.Widgets.ConceptMapView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    nodes = new Backbone.Collection
    nodes.tree = ->
      root:
        children: []
      edges: []
    @view = new Coreon.Views.Widgets.ConceptMapView
      model: nodes

  afterEach ->
    I18n.t.restore()

  it "is a simple view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates container", ->
    @view.$el.should.have.id "coreon-concept-map"
    @view.$el.should.have.class "widget"

  describe "initialize()", ->

    beforeEach ->
      Coreon.application =
        session:
          get: (attr) ->

    afterEach ->
      Coreon.application = null

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

      it "renders viewport", ->
        @view.options.size = [150, 120]
        @view.options.svgOffset = 25
        @view.initialize() 
        @view.$el.should.have "svg"
        @view.$("svg").attr("height").should.equal "95px"
        @view.$("svg").attr("width").should.equal "150px"

      it "creates resize handle", ->
        @view.initialize()
        @view.$el.should.have ".ui-resizable-s"

      context "fixing filter rendering", ->

        beforeEach ->
          @originalDevicePixelRatio = window.devicePixelRatio

        afterEach ->
          window.devicePixelRatio = @originalDevicePixelRatio

        it "increases filter resolution on retina displays", ->
          window.devicePixelRatio = 2
          @view.initialize()
          d3.select(@view.$("svg defs #drop-shadow").get 0).attr("filterRes").should.equal "900"

        it "keeps default on non-retina displays", ->
          window.devicePixelRatio = 1
          @view.initialize()
          expect( d3.select(@view.$("svg defs #drop-shadow").get 0).attr("filterRes") ).to.be.null

    context "preparing graph rendering", ->

      it "creates layout", ->
        layout = {}
        sinon.stub(d3.layout, "tree").returns layout
        try
          @view.initialize()
          @view.layout.should.equal layout
        finally
          d3.layout.tree.restore()

      it "creates diagonals factory", ->
        diagonal = d3.svg.diagonal()
        sinon.stub d3.svg, "diagonal", -> diagonal
        try
          @view.initialize()
          @view.stencil.should.equal diagonal
          @view.stencil.projection()(x: "x", y: "y").should.eql ["y", "x"]
        finally
          d3.svg.diagonal.restore()

    context "restoring from session", ->
      
      it "restores dimensions", ->
        Coreon.application.session.get = (attr) ->
          if attr is "coreon-concept-map"
            width: 123
            height: 456
        @view.resize = sinon.spy()
        @view.initialize()
        @view.resize.should.have.been.calledOnce
        @view.resize.should.have.been.calledWith 123, 456

  describe "render()", ->
  
    it "can be chained", ->
      @view.render().should.equal @view

    context "updates", ->
      
      beforeEach ->
        @clock = sinon.useFakeTimers()
        @view.render = sinon.spy()
        @view.initialize renderInterval: 0

      afterEach ->
        @clock.restore()

      it "is triggered after a reset", ->
        @view.model.trigger "reset"
        @clock.tick 200
        @view.render.should.have.been.calledOnce

      it "is triggered when a node was added", ->
        @view.model.trigger "add"
        @clock.tick 200
        @view.render.should.have.been.calledOnce

      it "is triggered when a node was removed", ->
        @view.model.trigger "remove"
        @clock.tick 200
        @view.render.should.have.been.calledOnce

      it "is triggered when a label changed", ->
        @view.model.trigger "change:label"
        @clock.tick 200
        @view.render.should.have.been.calledOnce

    context "nodes", ->
      
      it "does not render root node", ->
        @view.model.tree = ->
          root:
            children: []
          edges: []
        @view.render()
        @view.$el.should.not.have ".concept-node"

      context "updating svg elements", ->
          
        beforeEach ->
          @view.model.tree = ->
            root:
              children: [
                id: "node_1"
                model: new Backbone.Model(id: "node_1", label: "Node 1")
              ]
            edges: []
          @view.render()

        it "renders additional nodes", ->
          @view.model.tree = ->
            root:
              children: [
                { id: "node_1", model: new Backbone.Model(id: "node_1", label: "Node 1") }
                { id: "node_2", model: new Backbone.Model(id: "node_2", label: "Node 2") }
              ]
            edges: []
          @view.render()
          @view.$("svg g.concept-map .concept-node").should.have.lengthOf 2

        it "removes deprecated nodes", ->
          @view.model.tree = ->
            root:
              children: []
            edges: []
          @view.render()
          @view.$(".concept-node").should.not.exist

      context "updating positions", ->

        beforeEach ->
          @view.options.offsetX = 100
          @view.options.padding = 10

        it "resizes layout", ->
          @view.options.padding = 15
          @view.options.svgOffset = 18
          @view.resize 300, 220
          @view.layout.size = sinon.stub().returns @view.layout
          @view.render()
          @view.layout.size.should.have.been.calledOnce
          @view.layout.size.should.have.been.calledWith [ 202, 270 ]

        it "passes tree to layout", ->
          @view.layout.nodes = sinon.stub().returns [ id: "root" ]
          @view.render()
          @view.layout.nodes.should.have.been.calledOnce
          @view.layout.nodes.should.have.been.calledWith @view.model.tree().root
        
        it "updates node coordinates", ->
          @view.layout.nodes = ->
            [
              { id: "root" }
              {
                id: "node_1"
                model: new Backbone.Model(id: "node_1", label: "Node 1")
                depth: 3 
                x: 27
                y: 380
              }
              {
                id: "node_2"
                model: new Backbone.Model(id: "node_2", label: "Node 2")
                depth: 5 
                x: 154
                y: 560
              }
            ]
          @view.render()

          datum1 = d3.select( @view.$(".concept-node").get(0) ).data()[0]
          datum1.should.have.property "x", (3 - 1) * 100
          datum1.should.have.property "y", 27

          datum2 = d3.select( @view.$(".concept-node").get(1) ).data()[0]
          datum2.should.have.property "x", (5 - 1) * 100
          datum2.should.have.property "y", 154
          
        it "moves views to new position", ->
          @view.layout.nodes = ->
            [
              { id: "root" }
              {
                id: "node_1"
                model: new Backbone.Model(id: "node_1", label: "Node 1")
                depth: 3 
                x: 30
              }
            ]
          @view.render()
          @view.$(".concept-node").should.have.attr "transform", "translate(200, 30)"

      context "updating view instances", ->

        beforeEach ->
          @node = new Backbone.Model _id: "node", label: "Node"
          @node.cid = "c123"
          @view.model.tree = =>
            root:
              children: [
                id: "node"
                model: @node
              ]
            edges: []

        it "creates view for newly created node", ->
          @view.render()
          @view.views.should.have.property("c123").that.is.an.instanceof Coreon.Views.Concepts.ConceptNodeView
          @view.views.should.have.deep.property "c123.el", @view.$(".concept-node").get(0)
          @view.views.should.have.deep.property "c123.model", @node

        it "resolves view for removed views", ->
          @view.render()
          spy = sinon.spy()
          @view.views["c123"].stopListening = spy
          @view.model.tree = ->
            root:
              children: []
            edges: []
          @view.render()
          spy.should.have.been.calledOnce
          should.not.exist @view.views["c123"]
  
    context "edges", ->

      beforeEach ->
        @view.views =
          c_parent:  box: -> height: 0, width: 0
          c_child_1: box: -> height: 0, width: 0
          c_child_2: box: -> height: 0, width: 0

      it "renders newly added eges", ->
        @view.model.tree = ->
          root:
            children: []
          edges: [
            {
              source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent", has: -> false } }
              target: { id: "child_1", x: 0, y: 0, model: { cid: "c_child_1", has: -> false } }
            }
            {
              source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent", has: -> false } }
              target: { id: "child_2", x: 0, y: 0, model: { cid: "c_child_2", has: -> false } }
            }
          ]
        @view.render()
        @view.$el.should.have ".concept-edge"
        @view.$(".concept-edge").size().should.equal 2

      it "removes dropped edges", ->
        @view.model.tree = ->
          root: children: []
          edges: [
            {
              source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent", has: -> false } }
              target: { id: "child_1", x: 0, y: 0, model: { cid: "c_child_1", has: -> false } }
            }
          ]
        @view.render()
        @view.model.tree = ->
          root: children: []
          edges: []
        @view.render()
        @view.$el.should.not.have ".concept-edge"

      it "renders curves from box to box", ->
        @view.views =
          c_parent:  box: -> height: 30, width: 120
          c_child_1: box: -> height: 20, width: 150
        @view.model.tree = ->
          root: children: []
          edges: [
            source: { id: "parent",  x: 20, y: 25, model: { cid: "c_parent", has: -> false } }
            target: { id: "child_1", x: 40, y: 55, model: { cid: "c_child_1", has: -> false } }
          ]
        @view.render()
        @view.$(".concept-edge").attr("d").should.match /M140,40.*40,70/

  describe "zoomIn()", ->
  
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
      @view.render()
      @view.zoomIn()
      @view.$(".concept-map").attr("transform").should.contain "scale(1.5)"
      
  describe "zoomOut()", ->
  
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
      @view.render()
      @view.zoomIn()
      @view.$(".concept-map").attr("transform").should.contain "scale(1.5)"

  describe "resize()", ->

    beforeEach ->
      Coreon.application =
        session:
          save: sinon.spy()
      @clock = sinon.useFakeTimers()
      @view.$el.width 160
      @view.$el.height 120

    afterEach ->
      Coreon.application = null
      @clock.restore()
  
    it "is triggered when resize handle is dragged", ->
      $("#konacha").append @view.render().$el
      handle = @view.$(".ui-resizable-s")
      @view.resize = sinon.spy()
      handle.simulate "mouseover"
      handle.simulate "drag", dy: -24, moves: 1
      @view.resize.should.have.been.calledOnce
      @view.resize.should.have.been.calledWith null, 96

    it "adjusts el dimensions", ->
      @view.resize 67, 116
      @view.$el.height().should.equal 116
      @view.$el.width().should.equal 67

    it "keeps height when null", ->
      @view.resize 67, null
      @view.$el.height().should.equal 120
      @view.$el.width().should.equal 67

    it "keeps width when null", ->
      @view.resize null, 77
      @view.$el.height().should.equal 77
      @view.$el.width().should.equal 160

    it "adjusts svg dimensions", ->
      @view.options.svgOffset = 18
      @view.resize 200, 300
      svg = @view.$("svg")
      svg.should.have.attr "width", "200px"
      svg.should.have.attr "height", "282px"

    it "stores dimensions when finished", ->
      @view.resize 123, 334
      @clock.tick 1000
      Coreon.application.session.save.should.have.been.calledOnce
      Coreon.application.session.save.should.have.been.calledWith "coreon-concept-map",
        width: 123
        height: 334
