#= require spec_helper
#= require views/widgets/concept_map_view

describe "Coreon.Views.Widgets.ConceptMapView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    nodes = new Backbone.Collection
    nodes.tree = ->
      id: "root"
      children: []
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

  #   it "creates diagonals factory", ->
  #     diagonal = d3.svg.diagonal()
  #     sinon.stub d3.svg, "diagonal", -> diagonal
  #     try
  #       @view.initialize()
  #       @view.stencil.should.equal diagonal
  #       @view.stencil.projection()(x: "x", y: "y").should.eql ["y", "x"]
  #     finally
  #       d3.svg.diagonal.restore()

  describe "render()", ->
  
    it "can be chained", ->
      @view.render().should.equal @view

    it "is triggered by model changes", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce

    context "rendering nodes", ->

      it "does not render root node", ->
        @view.model.tree = ->
          id: "root"
          children: []
        @view.render()
        @view.$(".concept-node").should.not.exist

      context "updating svg elements", ->
          
        beforeEach ->
          @view.model.tree = ->
            id: "root"
            children: [
              id: "node_1"
              model: new Backbone.Model(id: "node_1")
            ]
          @view.render()

        it "renders additional nodes", ->
          @view.model.tree = ->
            id: "root"
            children: [
              { id: "node_1", model: new Backbone.Model(id: "node_1") }
              { id: "node_2", model: new Backbone.Model(id: "node_2") }
            ]
          @view.render()
          @view.$("svg g.concept-map .concept-node").should.have.lengthOf 2

        it "removes deprecated nodes", ->
          @view.model.tree = ->
            id: "root"
            children: []
          @view.render()
          @view.$(".concept-node").should.not.exist

      context "updating positions", ->

        beforeEach ->
          @view.options.size    = [120, 150]
          @view.options.offsetX = 100
        
        it "updates node coordinates", ->
          @view.layout.nodes = ->
            [
              { id: "root" }
              {
                id: "node_1"
                model: new Backbone.Model(id: "node_1")
                depth: 3 
                x: 0.2
                y: 0.75
              }
              {
                id: "node_2"
                model: new Backbone.Model(id: "node_2")
                depth: 5 
                x: 0.5
                y: 0.6
              }
            ]
          @view.render()

          datum1 = d3.select( @view.$(".concept-node").get(0) ).data()[0]
          datum1.should.have.property "x", 200
          datum1.should.have.property "y", 24

          datum2 = d3.select( @view.$(".concept-node").get(1) ).data()[0]
          datum2.should.have.property "x", 400
          datum2.should.have.property "y", 60
          
        it "moves nodes to new position", ->
          @view.layout.nodes = ->
            [
              { id: "root" }
              {
                id: "node_1"
                model: new Backbone.Model(id: "node_1")
                depth: 3 
                x: 0.2
              }
            ]
          @view.render()
          @view.$(".concept-node").should.have.attr "transform", "translate(200, 24)"

      context "updating view instances", ->

        it "creates view for newly created node", ->
          node = new Backbone.Model id: "node"
          @view.model.tree = ->
            id: "root"
            children: [
              id: "node"
              model: node
            ]
          @view.render()
          el = @view.$(".concept-node").get(0)
          datum = d3.select(el).data()[0]
          datum.should.have.property "view"
          datum.view.should.be.an.instanceof Coreon.Views.Concepts.ConceptNodeView
          datum.view.should.have.property "el", el 
          datum.view.should.have.property "model", node 

        it "resolves view for removed nodes", ->
          @view.model.tree = ->
            id: "root"
            children: [
              id: "node"
              model: new Backbone.Model(id: "node_1")
            ]
          @view.render()
          el = @view.$(".concept-node").get(0)
          datum = d3.select(el).data()[0]
          datum.view.stopListening = sinon.spy()
          @view.model.tree = -> id: "root"
          @view.render()
          datum.view.stopListening.should.have.been.calledOnce
          
        
        


  # describe "renderMap()", ->

  #   beforeEach ->
  #     @view.render()

  #   it "is triggered by current hits", ->
  #     @view.renderMap = sinon.spy()
  #     @view.initialize()
  #     @view.model.trigger "hit:update"
  #     @view.model.trigger "hit:change"
  #     @view.renderMap.should.have.been.calledTwice

  #   it "updates layout", ->
  #     @view.model.tree = -> id: "root"
  #     @view.layout.nodes = sinon.stub().returns []
  #     @view.renderMap()
  #     @view.layout.nodes.should.have.been.calledOnce
  #     @view.layout.nodes.should.have.been.calledWith id: "root"

  #   it "renders nodes", ->
  #     @view.layout.nodes = -> [ { id: "root" }, { id: "1" } ]
  #     @view.scaleY = -> 1.2
  #     @view.renderNodes = sinon.spy()
  #     @view.renderMap()
  #     @view.renderNodes.should.have.been.calledOnce
  #     @view.renderNodes.should.have.been.calledWith [ {id: "1" } ], 1.2

  #   it "renders edges", ->
  #     @view.model.edges = -> [ source: "A", target: "B" ]
  #     @view.renderEdges = sinon.spy()
  #     @view.renderMap()
  #     @view.renderEdges.should.have.been.calledOnce
  #     @view.renderEdges.should.have.been.calledWith [ source: "A", target: "B" ]

  #   it "centers horizontally", ->
  #     @view.centerY = sinon.spy()
  #     @view.renderMap()
  #     @view.centerY.should.have.been.calledOnce

  # describe "renderNodes()", ->
  # 
  #   beforeEach ->
  #     @view.render()
  #     $("#konacha").append @view.$el
  #     @view.model.tree = -> {}
  #     @view.layout.nodes = -> []

  #   it "creates new concept nodes", ->
  #     @view.renderNodes [
  #       { id: "1", concept: @createConcept("Pistol"), treeDown: [], treeUp: [] }
  #       { id: "2", concept: @createConcept("Revolver"), treeDown: [], treeUp: [] }
  #     ]
  #     @view.$el.should.have ".concept-node"
  #     @view.$(".concept-node").size().should.equal 2
  #     ($(label).text() for label in @view.$(".concept-node")).join("|").should.equal "Pistol|Revolver"

  #   it "updates nodes", ->
  #     concept = @createConcept("Pistol")
  #     @view.renderNodes [ id: "1", concept: concept, depth: 1, x: 0, y: 0, treeUp: [], treeDown: [] ], 2
  #     @view.views["1"].render = sinon.spy()
  #     @view.renderNodes [ id: "1", concept: concept, depth: 2, x: 23, y: 48.6, treeUp: ["2"], treeDown: ["7"] ], 2
  #     @view.$(".concept-node").attr("transform").should.equal "translate(120, 46)"
  #     @view.views["1"].options.should.have.property "treeRoot", false
  #     @view.views["1"].options.should.have.property "treeLeaf", false
  #     @view.views["1"].render.should.have.been.calledOnce

  #   it "updates box dimensions", ->
  #     node = id: "1", concept: @createConcept("Pistol"), depth: 2, x: 23, y: 48.6, treeUp: [], treeDown: []
  #     sinon.stub SVGRectElement::, "getBBox", -> x: 0, y: 0, height: 20, width: 48
  #     try
  #       @view.renderNodes [ node ], 2
  #       node.box.should.have.property "height", 20
  #       node.box.should.have.property "width", 48
  #     finally
  #       SVGRectElement::getBBox.restore()

  #   it "removes deprecated nodes", ->
  #     @view.renderNodes [
  #       { id: "1", concept: @createConcept("Pistol"), treeUp: [], treeDown: [] }
  #       { id: "2", concept: @createConcept("Revolver"), treeUp: [], treeDown: [] }
  #     ] 
  #     @view.renderNodes [
  #       { id: "2", concept: @createConcept("Revolver"), treeUp: [], treeDown: [] }
  #     ] 
  #     @view.$(".concept-node").size().should.equal 1
  #     @view.$(".concept-node").text().should.equal "Revolver"

  #   it "creates view for enter node", ->
  #     nodes = [ id: "1", concept: @createConcept("Pistol"), treeUp: [], treeDown: [] ]
  #     @view.renderNodes nodes
  #     expect(@view.views["1"]).to.exist
  #     @view.views["1"].should.be.an.instanceof Coreon.Views.Concepts.ConceptNodeView
  #     @view.views["1"].should.have.property "el", @view.$(".concept-node").get(0)
  #     @view.views["1"].should.have.property "model", nodes[0].concept
  #     @view.views["1"].options.should.have.property "treeRoot", true
  #     @view.views["1"].options.should.have.property "treeLeaf", true

  #   it "dissolves view for exit node", ->
  #     nodes = [ id: "1", concept: @createConcept("Pistol"), treeUp: [], treeDown: [] ]
  #     @view.renderNodes nodes
  #     nodeView = @view.views["1"]
  #     nodeView.dissolve = sinon.spy()
  #     @view.renderNodes []
  #     @view.renderMap()
  #     expect(@view.views["1"]).to.not.exist
  #     nodeView.dissolve.should.have.been.calledOnce 

  #   it "stores dimensions on datum", ->
  #     nodes = [ id: "1", concept: @createConcept("Pistol"), treeUp: [], treeDown: [] ]
  #     @view.renderNodes nodes
  #     nodes[0].should.have.property "box"

  # describe "renderEges()", ->

  #   beforeEach ->
  #     @view.render()
  #     $("#konacha").append @view.$el
  #   
  #   it "draws new edges", ->
  #     @view.renderEdges [
  #       {
  #         source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
  #         target: { id: "b", x: 40, y: 55 }
  #       }
  #       {
  #         source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
  #         target: { id: "c", x: 70, y: 75 }
  #       }
  #     ]
  #     @view.$el.should.have ".concept-edge"
  #     @view.$(".concept-edge").size().should.equal 2

  #   it "redraws edges", ->
  #     @view.renderEdges [
  #       source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
  #       target: { id: "b", x: 40, y: 55, box: { height: 20, width: 50 } }
  #     ]
  #     @view.$(".concept-edge").attr("d").should.match /M70,35.*40,65/

  #   it "erases deprecated edges", ->
  #     @view.renderEdges [
  #       {
  #         source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
  #         target: { id: "b", x: 40, y: 55, box: { height: 20, width: 50 } }
  #       }
  #       {
  #         source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
  #         target: { id: "c", x: 70, y: 75, box: { height: 20, width: 50 } }
  #       }
  #     ] 
  #     @view.renderEdges [
  #       source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
  #       target: { id: "c", x: 70, y: 75, box: { height: 20, width: 50 } }
  #     ] 
  #     @view.$(".concept-edge").size().should.equal 1

  # describe "scaleY()", ->
  # 
  #   it "stretches height to fit concepts vertically", ->
  #    nodes = [
  #       { id: "root" }
  #       { id: "1", concept: @createConcept("Pistol"),   depth: 2, x: 10 }
  #       { id: "2", concept: @createConcept("Revolver"), depth: 2, x: 20 }
  #     ]
  #     nodes[0].children = nodes[1..]
  #     @view.layout.nodes = -> nodes
  #     @view.scaleY(nodes).should.equal 2.2

  # describe "centerY()", ->
  #   
  #   beforeEach ->
  #     @view.render()
  #     @map = @view.$("svg .concept-map")
  #     @map.get(0).getBBox = sinon.stub()

  #   it "moves slightly towards center when not higher than viewport", ->
  #     @map.get(0).getBBox.returns x: 0, y: 0, width: 100, height: 45
  #     @view.centerY()
  #     @map.attr("transform").should.equal "translate(10, -10)"

  #   it "centers vertically when higher than viewport", ->
  #     @map.get(0).getBBox.returns x: 0, y: 0, width: 100, height: 450
  #     @view.centerY()
  #     @map.attr("transform").should.equal "translate(10, -135)"

  # describe "onToggleChildren()", ->

  #   beforeEach ->
  #     graph =
  #       add: ->
  #       remove: ->
  #     @view.model.graph = -> graph
  #     @view.render()
  #   
  #   it "is triggered by view instances", ->
  #     @view.onToggleChildren = sinon.spy()
  #     @view.renderNodes [ id: "1", concept: @createConcept("Pistol"), treeUp: [], treeDown: [] ]
  #     @view.views["1"].trigger "toggle:children", id: "123"
  #     @view.onToggleChildren.should.have.been.calledOnce
  #     @view.onToggleChildren.should.have.been.calledWith id: "123"

  #   context "when collapsed", ->

  #     beforeEach ->
  #       @node =
  #         treeDown: []
  #         concept:
  #           get: ->
  #     
  #     it "adds nodes to graph", ->
  #       @node.concept.get = (attr) -> [ "child1", "child2" ] if attr is "sub_concept_ids"
  #       @view.model.graph().add = sinon.spy()
  #       @view.onToggleChildren @node
  #       @view.model.graph().add.should.have.been.calledOnce
  #       @view.model.graph().add.firstCall.args[0].should.be.an "array"
  #       @view.model.graph().add.firstCall.args[0].should.have.length 2
  #       @view.model.graph().add.firstCall.args[0][0].should.be.an.instanceof Coreon.Models.Hit
  #       @view.model.graph().add.firstCall.args[0][0].id.should.equal "child1"
  #       @view.model.graph().add.firstCall.args[0][1].should.be.an.instanceof Coreon.Models.Hit
  #       @view.model.graph().add.firstCall.args[0][1].id.should.equal "child2"

  #     it "updates rendering of map"
  #       

  #   context "when expanded", ->
  #     
  #     beforeEach ->
  #       @node =
  #         treeDown: [ id: "123" ]
  #       @view.model.graph().remove = sinon.spy()

  #     it "removes nodes from graph", ->
  #       @node.treeDown = [
  #         { id: "child_1" }
  #         { id: "child_2" }
  #       ]
  #       @view.onToggleChildren @node
  #       @view.model.graph().remove.should.have.been.calledOnce
  #       @view.model.graph().remove.should.have.been.calledWith "child_1", "child_2"

  #     it "removes nodes recursively", ->
  #       @node.treeDown = [
  #         id: "child"
  #         treeDown: [ id: "child_of_child"]
  #       ]
  #       @view.onToggleChildren @node
  #       @view.model.graph().remove.should.have.been.calledOnce
  #       @view.model.graph().remove.should.have.been.calledWith "child", "child_of_child"


  #     it "does not remove nodes that have outer parents", ->
  #       @node.treeDown = [
  #         id: "child"
  #         treeDown: [ id: "child_of_child"]
  #         parents: [ @node, { id: "other" } ]
  #       ]
  #       @view.onToggleChildren @node
  #       @view.model.graph().remove.should.not.have.been.called

  #     it "updates rendering of map"

  # describe "onToggleParents()", ->

  #   beforeEach ->
  #     graph =
  #      add: ->
  #      remove: ->
  #     @view.model.graph = -> graph
  #     @view.render()
  #   
  #   it "is triggered by view instances", ->
  #     @view.onToggleParents = sinon.spy()
  #     @view.renderNodes [ id: "1", concept: @createConcept("Pistol"), treeUp: [], treeDown: [] ]
  #     @view.views["1"].trigger "toggle:parents", id: "123"
  #     @view.onToggleParents.should.have.been.calledOnce
  #     @view.onToggleParents.should.have.been.calledWith id: "123"

  #   context "when collapsed", ->

  #     beforeEach ->
  #       @node =
  #         treeUp: []
  #         concept:
  #           get: ->
  #       @view.model.graph().add = sinon.spy()
  #     
  #     it "adds nodes to graph", ->
  #       @node.concept.get = (attr) -> [ "parent1", "parent2" ] if attr is "super_concept_ids"
  #       @view.onToggleParents @node
  #       @view.model.graph().add.should.have.been.calledOnce
  #       @view.model.graph().add.firstCall.args[0].should.be.an "array"
  #       @view.model.graph().add.firstCall.args[0].should.have.length 2
  #       @view.model.graph().add.firstCall.args[0][0].should.be.an.instanceof Coreon.Models.Hit
  #       @view.model.graph().add.firstCall.args[0][0].should.have.property "id", "parent1"
  #       @view.model.graph().add.firstCall.args[0][0].get("expandChildren").should.be.true
  #       @view.model.graph().add.firstCall.args[0][1].should.be.an.instanceof Coreon.Models.Hit
  #       @view.model.graph().add.firstCall.args[0][1].id.should.equal "parent2"
  #       @view.model.graph().add.firstCall.args[0][1].get("expandChildren").should.be.true

  # describe "dissolve()", ->

  #   it "dissolves hits", ->
  #     @view.model.off = sinon.spy()
  #     @view.dissolve()
  #     @view.model.off.should.have.been.calledOnce
  #     @view.model.off.should.have.been.calledWith null, null, @view
