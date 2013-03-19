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

    beforeEach ->
      Coreon.application =
        session:
          get: (attr) ->

    afterEach ->
      Coreon.application = null

    it "creates search", ->
      @view.search.should.be.an.instanceOf Coreon.Views.Widgets.SearchView

    it "creates concept map", ->
      @view.map.should.be.an.instanceOf Coreon.Views.Widgets.ConceptMapView
      @view.map.model.should.be.an.instanceof Coreon.Collections.ConceptNodes
      @view.map.model.should.have.property "hits", @view.model.hits

    it "creates resize handle", ->
      @view.$el.should.have ".ui-resizable-w"

    it "restores width from session", ->
      Coreon.application.session.get = (attr) ->
        width: 347 if attr is "coreon-widgets"
      @view.initialize()
      @view.$el.width().should.equal 347

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
      @view.map.render.should.have.property "callCount", 1

    it "renders map only once", ->
      @view.render()
      @view.render()
      @view.$("#coreon-concept-map").size().should.equal 1

  describe "resizing", ->

    beforeEach ->
      Coreon.application =
        session:
          save: sinon.spy()
      @clock = sinon.useFakeTimers()
      $("#konacha").append @view.render().$el
      @handle = @view.$(".ui-resizable-w")
      @handle.drag = (deltaX) =>
        @handle.simulate "mouseover"
        @handle.simulate "drag", dx: deltaX, moves: 1

    afterEach ->
      Coreon.application = null
      @clock.restore()

    it "adjusts width when dragging resize handler", ->
      @view.$el.width 320
      @handle.drag -47
      @view.$el.width().should.equal 367

    it "syncs svg width", ->
      @view.$el.width 320
      @view.map.resize = sinon.spy()
      @handle.drag -47
      @view.map.resize.should.have.been.calledOnce
      @view.map.resize.should.have.been.calledWith 367, null

    it "does not allow to reduce width below min width", ->
      @view.$el.width 320
      @handle.drag 300
      @view.$el.width().should.equal 240

    it "restores left positioning after drag", ->
      @handle.drag 25
      @view.$el.css("left").should.equal "auto"

    it "stores width when finished", ->
      @view.$el.width 300
      @handle.drag -20
      @clock.tick 1000
      Coreon.application.session.save.should.have.been.calledWith "coreon-widgets", width: 320
