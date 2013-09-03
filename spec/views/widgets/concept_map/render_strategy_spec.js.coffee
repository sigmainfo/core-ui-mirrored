#= require spec_helper
#= require views/widgets/concept_map/render_strategy

describe "Coreon.Views.Widgets.ConceptMap.RenderStrategy", ->

  beforeEach ->
    sinon.stub d3.layout, "tree", => @layout = size: sinon.spy()
    sinon.stub d3.svg, "diagonal", => @diagonal = {}
    @selection = selectAll: ->
    @strategy = new Coreon.Views.Widgets.ConceptMap.RenderStrategy @selection, d3.layout.tree() 

  afterEach ->
    d3.layout.tree.restore()
    d3.svg.diagonal.restore()
  
  describe "constructor()", ->
  
    it "stores selection reference", ->
      @strategy.should.have.property "selection", @selection

    it "creates layout instance", ->
      @strategy.should.have.property "layout", @layout

    it "creates stencil for drawing edges", ->
      @strategy.should.have.property "diagonal", @diagonal

  describe "resize()", ->
    
    it "sets width and height values", ->
      @strategy.resize 320, 240
      @strategy.should.have.property "width", 320
      @strategy.should.have.property "height", 240

  describe "render()", ->

    beforeEach ->
      @tree =
        root: {}
        edges: {}

    it "renders nodes", ->
      @strategy.renderNodes = sinon.spy()
      @strategy.render @tree
      @strategy.renderNodes.should.have.been.calledOnce
      @strategy.renderNodes.should.have.been.calledWith @tree.root
      
    it "renders edges", ->
      @strategy.renderEdges = sinon.spy()
      @strategy.render @tree
      @strategy.renderEdges.should.have.been.calledOnce
      @strategy.renderEdges.should.have.been.calledWith @tree.edges
