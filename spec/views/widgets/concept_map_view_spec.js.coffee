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

    context "rendering markup skeleton", ->
      
      it "renders titlebar", ->
        I18n.t.withArgs("concept-map.title").returns "Concept Map"
        @view.initialize()
        @view.$el.should.have ".titlebar h4"
        @view.$(".titlebar h4").should.have.text "Concept Map"

      it "renders viewport", ->
        @view.options.size = [120, 150]
        @view.initialize() 
        @view.$el.should.have "svg"
        @view.$("svg").attr("height").should.equal "120"
        @view.$("svg").attr("width").should.equal "150"

      it "defaults viewport dimensions", ->
        @view.initialize() 
        @view.$("svg").attr("height").should.equal "200"
        @view.$("svg").attr("width").should.equal "320"

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

  describe "render()", ->
  
    it "can be chained", ->
      @view.render().should.equal @view

    context "updates", ->
      
      beforeEach ->
        @view.render = sinon.spy()
        @view.initialize renderInterval: 0

      it "is triggered after a reset", (done) ->
        @view.model.trigger "reset"
        _.defer =>
          @view.render.should.have.been.calledOnce
          done()

      it "is triggered when a node was added", (done) ->
        @view.model.trigger "add"
        _.defer =>
          @view.render.should.have.been.calledOnce
          done()

      it "is triggered when a node was removed", (done) ->
        @view.model.trigger "remove"
        _.defer =>
          @view.render.should.have.been.calledOnce
          done()

      it "is triggered when a label changed", (done) ->
        @view.model.trigger "change:label"
        _.defer =>
          @view.render.should.have.been.calledOnce
          done()

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
          @view.options.size    = [120, 150]
          @view.options.offsetX = 100
          @view.options.padding = 10
        
        it "updates node coordinates", ->
          @view.layout.nodes = ->
            [
              { id: "root" }
              {
                id: "node_1"
                model: new Backbone.Model(id: "node_1", label: "Node 1")
                depth: 3 
                x: 0.2
                y: 0.75
              }
              {
                id: "node_2"
                model: new Backbone.Model(id: "node_2", label: "Node 2")
                depth: 5 
                x: 0.5
                y: 0.6
              }
            ]
          @view.render()

          datum1 = d3.select( @view.$(".concept-node").get(0) ).data()[0]
          datum1.should.have.property "x", 2 * 100 + 10
          datum1.should.have.property "y", (120 - 2 * 10) * 0.2 + 10

          datum2 = d3.select( @view.$(".concept-node").get(1) ).data()[0]
          datum2.should.have.property "x", 4 * 100 + 10
          datum2.should.have.property "y", (120 - 2 * 10) * 0.5 + 10
          
        it "moves nodes to new position", ->
          @view.layout.nodes = ->
            [
              { id: "root" }
              {
                id: "node_1"
                model: new Backbone.Model(id: "node_1", label: "Node 1")
                depth: 3 
                x: 0.2
              }
            ]
          @view.render()
          @view.$(".concept-node").should.have.attr "transform", "translate(210, 30)"

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
          @view.nodes.should.have.property("c123").that.is.an.instanceof Coreon.Views.Concepts.ConceptNodeView
          @view.nodes.should.have.deep.property "c123.el", @view.$(".concept-node").get(0)
          @view.nodes.should.have.deep.property "c123.model", @node

        it "resolves view for removed nodes", ->
          @view.render()
          spy = sinon.spy()
          @view.nodes["c123"].stopListening = spy
          @view.model.tree = ->
            root:
              children: []
            edges: []
          @view.render()
          spy.should.have.been.calledOnce
          should.not.exist @view.nodes["c123"]
  
    context "edges", ->

      beforeEach ->
        @view.nodes =
          c_parent:  box: -> height: 0, width: 0
          c_child_1: box: -> height: 0, width: 0
          c_child_2: box: -> height: 0, width: 0

      it "renders newly added eges", ->
        @view.model.tree = ->
          root:
            children: []
          edges: [
            {
              source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent" } }
              target: { id: "child_1", x: 0, y: 0, model: { cid: "c_child_1" } }
            }
            {
              source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent" } }
              target: { id: "child_2", x: 0, y: 0, model: { cid: "c_child_2" } }
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
              source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent" } }
              target: { id: "child_1", x: 0, y: 0, model: { cid: "c_child_1" } }
            }
          ]
        @view.render()
        @view.model.tree = ->
          root: children: []
          edges: []
        @view.render()
        @view.$el.should.not.have ".concept-edge"

      it "renders curves from box to box", ->
        @view.nodes =
          c_parent:  box: -> height: 30, width: 120
          c_child_1: box: -> height: 20, width: 150
        @view.model.tree = ->
          root: children: []
          edges: [
            source: { id: "parent",  x: 20, y: 25, model: { cid: "c_parent" } }
            target: { id: "child_1", x: 40, y: 55, model: { cid: "c_child_1" } }
          ]
        @view.render()
        @view.$(".concept-edge").attr("d").should.match /M140,40.*40,70/
