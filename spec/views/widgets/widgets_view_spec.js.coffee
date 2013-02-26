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

    it "creates resize handle", ->
      @view.$el.should.have ".ui-resizable-w"

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

    it "renders search only once", ->
      @view.render()
      @view.render()
      @view.$("#coreon-search").size().should.equal 1

    it "renders map", ->
      @view.render()
      @view.$el.should.have "#coreon-concept-map"
      @view.map.render.should.have.been.calledOnce

    it "renders map only once", ->
      @view.render()
      @view.render()
      @view.$("#coreon-concept-map").size().should.equal 1

  describe "resizing()", ->

    beforeEach ->
      $("#konacha").append @view.render().$el
      @handle = @view.$(".ui-resizable-w")
      @handle.drag = (deltaX) =>
        @handle.simulate "mouseover"
        @handle.simulate "drag", dx: deltaX

    it "adjusts width when dragging resize handler", ->
      @view.$el.width 320
      @handle.drag -47
      @view.$el.width().should.equal 367

    it "does not allow to reduce width below min width", ->
      @view.$el.width 320
      @handle.drag 300
      @view.$el.width().should.equal 240

    it "restores left positioning after drag", ->
      @handle.drag 25
      @view.$el.css("left").should.equal "auto"
