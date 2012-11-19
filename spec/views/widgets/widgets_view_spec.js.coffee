#= require spec_helper
#= require views/widgets/widgets_view

describe "Coreon.Views.Widgets.WidgetsView", ->

  beforeEach ->
    @view = new Coreon.Views.Widgets.WidgetsView
    sinon.stub @view.search
    sinon.stub @view.map

  it "is a composite view", ->
    @view.should.be.an.instanceOf Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.have.id "coreon-widgets"

  it "creates subviews", ->
    @view.search.should.be.an.instanceOf Coreon.Views.Widgets.SearchView
    @view.map.should.be.an.instanceOf Coreon.Views.Widgets.ConceptMapView
    
  describe "#render", ->

    beforeEach ->
      @view.search.render.returns @view.search
      @view.map.render.returns @view.map

    it "is chainable", ->
      @view.render().should.equal @view
    
    it "renders search", ->
      @view.render()
      @view.$el.should.have "#coreon-search"
      @view.search.render.should.have.been.calledOnce

    it "renders map", ->
      @view.render()
      @view.$el.should.have "#coreon-concept-map"
      @view.map.render.should.have.been.calledOnce
