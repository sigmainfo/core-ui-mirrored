#= require spec_helper
#= require views/widgets/concept_map_view

describe "Coreon.Views.Widgets.ConceptMapView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.ConceptMapView
      model: new Backbone.Collection
    @view.model.tree = -> children: []

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

    beforeEach ->
      @view.render()
      $("#konacha").append @view.$el
      @view.model.tree = -> {}
      @view.layout.nodes = -> []
      @createConcept = (label) ->
        concept = new Backbone.Model
        concept.label = -> label
        concept
    
    it "is triggered by current hits", ->
      @view.onHitUpdate = sinon.spy()
      @view.initialize()
      @view.model.trigger "hit:update"
      @view.onHitUpdate.should.have.been.calledOnce

    it "updates layout", ->
      @view.model.tree = -> id: "root"
      @view.layout.nodes = sinon.stub().returns []
      @view.onHitUpdate()
      @view.layout.nodes.should.have.been.calledOnce
      @view.layout.nodes.should.have.been.calledWith id: "root"

    it "renders concept nodes", ->
      @view.layout.nodes = => [
        { id: "root" }
        { id: "1", concept: @createConcept "Pistol"   }
        { id: "2", concept: @createConcept "Revolver" }
      ] 
      @view.onHitUpdate()
      @view.$el.should.have ".concept-node"
      @view.$(".concept-node").size().should.equal 2
      ($(label).text() for label in @view.$(".concept-node")).join("|").should.equal "Pistol|Revolver"

    it "removes deprecated nodes", ->
      @view.layout.nodes = => [
        { id: "root" }
        { id: "1", concept: @createConcept "Pistol"   }
        { id: "2", concept: @createConcept "Revolver" }
      ] 
      @view.onHitUpdate()
      @view.layout.nodes = => [
        { id: "root" }
        { id: "2", concept: @createConcept "Revolver" }
      ] 
      @view.onHitUpdate()
      @view.$(".concept-node").size().should.equal 1
      @view.$(".concept-node").text().should.equal "Revolver"

    it "creates view for enter node", ->
      nodes = [
        { id: "root" }
        { id: "1", concept: @createConcept "Pistol" }
      ]
      @view.layout.nodes = -> nodes
      @view.onHitUpdate()
      nodes[1].should.have.property "view"
      nodes[1].view.should.be.an.instanceof Coreon.Views.Concepts.ConceptNodeView
      nodes[1].view.should.have.property "el", @view.$(".concept-node").get(0)
      nodes[1].view.should.have.property "model", nodes[1].concept

    it "destroys view for exit node", ->
      nodes = [
        { id: "root" }
        { id: "1", concept: @createConcept "Pistol" }
      ]
      @view.layout.nodes = -> nodes
      @view.onHitUpdate()
      nodeView = nodes[1].view
      nodeView.destroy = sinon.spy()
      @view.layout.nodes = -> []
      @view.onHitUpdate()
      expect(nodes[1].view).to.be.null
      nodeView.destroy.should.have.been.calledOnce 
      

  describe "dissolve()", ->

    it "dissolves hits", ->
      @view.model.off = sinon.spy()
      @view.dissolve()
      @view.model.off.should.have.been.calledOnce
      @view.model.off.should.have.been.calledWith null, null, @view
