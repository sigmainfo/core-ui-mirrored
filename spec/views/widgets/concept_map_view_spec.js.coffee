#= require spec_helper
#= require views/widgets/concept_map_view

describe "Coreon.Views.Widgets.ConceptMapView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.ConceptMapView
      model: new Backbone.Collection
    @view.model.tree = -> children: []
    @view.model.edges = -> children: []

  afterEach ->
    I18n.t.restore()

  it "is a simple view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates container", ->
    @view.$el.should.have.id "coreon-concept-map"
    @view.$el.should.have.class "widget"

  describe "initialize()", ->
    
    it "creates layout", ->
      layout = d3.layout.tree()
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

    it "renders titlebar", ->
      I18n.t.withArgs("concept-map.title").returns "Concept Map"
      @view.render()
      @view.$el.should.have ".titlebar h4"
      @view.$(".titlebar h4").should.have.text "Concept Map"

    it "renders viewport", ->
      @view.render()
      @view.$el.should.have "svg"

  describe "onHitUpdate()", ->

    it "is triggered by current hits", ->
      @view.onHitUpdate = sinon.spy()
      @view.initialize()
      @view.model.trigger "hit:update"
      @view.model.trigger "hit:graph:update"
      @view.onHitUpdate.should.have.been.calledTwice

    it "updates layout", ->
      @view.model.tree = -> id: "root"
      @view.layout.nodes = sinon.stub().returns []
      @view.onHitUpdate()
      @view.layout.nodes.should.have.been.calledOnce
      @view.layout.nodes.should.have.been.calledWith id: "root"

    it "renders nodes", ->
      @view.layout.nodes = -> [ { id: "root" }, { id: "1" } ]
      @view.scaleY = -> 1.2
      @view.renderNodes = sinon.spy()
      @view.onHitUpdate()
      @view.renderNodes.should.have.been.calledOnce
      @view.renderNodes.should.have.been.calledWith [ {id: "1" } ], 1.2

    it "renders edges", ->
      @view.model.edges = -> [ source: "A", target: "B" ]
      @view.renderEdges = sinon.spy()
      @view.onHitUpdate()
      @view.renderEdges.should.have.been.calledOnce
      @view.renderEdges.should.have.been.calledWith [ source: "A", target: "B" ]

  describe "renderNodes()", ->
  
    beforeEach ->
      @view.render()
      $("#konacha").append @view.$el
      @view.model.tree = -> {}
      @view.layout.nodes = -> []
      @createConcept = (label) ->
        concept = new Backbone.Model
        concept.label = -> label
        concept.hit = -> false
        concept 

    it "renders concept nodes", ->
      @view.renderNodes [
        { id: "1", concept: @createConcept "Pistol"   }
        { id: "2", concept: @createConcept "Revolver" }
      ]
      @view.$el.should.have ".concept-node"
      @view.$(".concept-node").size().should.equal 2
      ($(label).text() for label in @view.$(".concept-node")).join("|").should.equal "Pistol|Revolver"

    it "updates node positions", ->
      @view.renderNodes [ id: "1", concept: @createConcept("Pistol"), depth: 2, x: 23, y: 48.6 ], 2
      @view.$(".concept-node").attr("transform").should.equal "translate(100, 46)"

    it "removes deprecated nodes", ->
      @view.renderNodes [
        { id: "1", concept: @createConcept "Pistol"   }
        { id: "2", concept: @createConcept "Revolver" }
      ] 
      @view.renderNodes [
        { id: "2", concept: @createConcept "Revolver" }
      ] 
      @view.$(".concept-node").size().should.equal 1
      @view.$(".concept-node").text().should.equal "Revolver"

    it "creates view for enter node", ->
      nodes = [ id: "1", concept: @createConcept "Pistol" ]
      @view.renderNodes nodes
      nodes[0].should.have.property "view"
      nodes[0].view.should.be.an.instanceof Coreon.Views.Concepts.ConceptNodeView
      nodes[0].view.should.have.property "el", @view.$(".concept-node").get(0)
      nodes[0].view.should.have.property "model", nodes[0].concept

    it "dissolves view for exit node", ->
      nodes = [ id: "1", concept: @createConcept "Pistol" ]
      @view.renderNodes nodes
      nodeView = nodes[0].view
      nodeView.dissolve = sinon.spy()
      @view.renderNodes []
      @view.onHitUpdate()
      expect(nodes[0].view).to.be.null
      nodeView.dissolve.should.have.been.calledOnce 

    it "stores dimensions on datum", ->
      nodes = [ id: "1", concept: @createConcept "Pistol" ]
      @view.renderNodes nodes
      nodes[0].should.have.property "box"

  describe "renderEges()", ->

    beforeEach ->
      @view.render()
      $("#konacha").append @view.$el
    
    it "draws new edges", ->
      @view.renderEdges [
        {
          source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
          target: { id: "b", x: 40, y: 55 }
        }
        {
          source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
          target: { id: "c", x: 70, y: 75 }
        }
      ]
      @view.$el.should.have ".concept-edge"
      @view.$(".concept-edge").size().should.equal 2

    it "redraws edges", ->
      @view.renderEdges [
        source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
        target: { id: "b", x: 40, y: 55, box: { height: 20, width: 50 } }
      ]
      @view.$(".concept-edge").attr("d").should.match /M70,35.*40,65/

    it "erases deprecated edges", ->
      @view.renderEdges [
        {
          source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
          target: { id: "b", x: 40, y: 55, box: { height: 20, width: 50 } }
        }
        {
          source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
          target: { id: "c", x: 70, y: 75, box: { height: 20, width: 50 } }
        }
      ] 
      @view.renderEdges [
        source: { id: "a", x: 20, y: 25, box: { height: 20, width: 50 } }
        target: { id: "c", x: 70, y: 75, box: { height: 20, width: 50 } }
      ] 
      @view.$(".concept-edge").size().should.equal 1



  describe "scaleY()", ->
  
    it "stretches height to fit concepts vertically", ->
     nodes = [
        { id: "root" }
        { id: "1", concept: @createConcept("Pistol"),   depth: 2, x: 10 }
        { id: "2", concept: @createConcept("Revolver"), depth: 2, x: 25 }
      ]
      nodes[0].children = nodes[1..]
      @view.layout.nodes = -> nodes
      @view.scaleY(nodes).should.equal 2

  describe "dissolve()", ->

    it "dissolves hits", ->
      @view.model.off = sinon.spy()
      @view.dissolve()
      @view.model.off.should.have.been.calledOnce
      @view.model.off.should.have.been.calledWith null, null, @view
