#= require spec_helper
#= require views/widgets/widgets_view

describe "Coreon.Views.Widgets.WidgetsView", ->

  beforeEach ->
    @view = new Coreon.Views.Widgets.WidgetsView
      model:
        hits: new Backbone.Collection

  it "is a composite view", ->
    @view.should.be.an.instanceOf Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.have.id "coreon-widgets"

  describe "initialize()", ->

    it "creates search", ->
      @view.search.should.be.an.instanceOf Coreon.Views.Widgets.SearchView

    it "creates concept map", ->
      @view.map.should.be.an.instanceOf Coreon.Views.Widgets.ConceptMapView
      @view.map.model.should.be.an.instanceof Coreon.Collections.ConceptNodes
      @view.map.model.should.have.property "hits", @view.model.hits
    
  describe "render()", ->

    beforeEach ->
      @view.search.render = sinon.stub().returns @view.search
      @view.map.render = sinon.stub().returns @view.map

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
