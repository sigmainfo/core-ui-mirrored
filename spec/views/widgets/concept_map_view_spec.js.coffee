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
      sinon.stub d3.layout, "tree", -> "tree layout"
      try
        @view.initialize()
        @view.layout.should.equal "tree layout"
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

  describe "_onHitUpdate()", ->
    
    it "is triggered by current hits", ->
      @view._onHitUpdate = sinon.spy()
      @view.initialize()
      @view.model.trigger "hit:update"
      @view._onHitUpdate.should.have.been.calledOnce

    it "updates layout", ->
      @view.model.tree = sinon.stub().returns children: ["foo", "bar"]
      @view.layout.nodes = sinon.spy()
      @view._onHitUpdate()
      @view.layout.nodes.should.have.been.calledOnce
      @view.layout.nodes.should.have.been.calledWith children: ["foo", "bar"]

    it "updates nodes"

    it "updates links"
      

  describe "dissolve()", ->

    it "dissolves hits", ->
      @view.model.off = sinon.spy()
      @view.dissolve()
      @view.model.off.should.have.been.calledOnce
      @view.model.off.should.have.been.calledWith null, null, @view
