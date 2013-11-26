#= require spec_helper
#= require views/widgets/widgets_view

describe "Coreon.Views.Widgets.WidgetsView", ->

  beforeEach ->
    Coreon.application = new Backbone.Model
    Coreon.application.cacheId =-> "face42"
    Coreon.application.repositorySettings =-> {}

    sinon.stub Coreon.Collections, "ConceptMapNodes", =>
      @nodes = new Backbone.Collection

    sinon.stub Coreon.Collections.Hits, "collection", =>
      @hits ?= new Backbone.Collection

    sinon.stub Coreon.Models, "SearchType", =>
      @searchType = new Backbone.Model

    sinon.stub Coreon.Views.Widgets, "SearchView", =>
      @search = new Backbone.View
      @search.render = sinon.stub().returns @search
      @search

    sinon.stub Coreon.Views.Widgets, "LanguagesView", =>
      @languages = new Backbone.View
      @languages.render = sinon.stub().returns @languages
      @languages

    sinon.stub Coreon.Views.Widgets, "ClipboardView", =>
      @clips = new Backbone.View
      @clips.render = sinon.stub().returns @clips
      @clips

    sinon.stub Coreon.Views.Widgets, "ConceptMapView", =>
      @map = new Backbone.View
      @map.render = sinon.stub().returns @map
      @map.resize = sinon.spy()
      @map

    sinon.stub Coreon.Views.Widgets, "TermListView", =>
      @terms = new Backbone.View
      @terms.render = sinon.stub().returns @terms
      @terms

    @view = new Coreon.Views.Widgets.WidgetsView
      model: new Backbone.Collection
        hits: new Backbone.Collection

  afterEach ->
    Coreon.Collections.ConceptMapNodes.restore()
    Coreon.Collections.Hits.collection.restore()
    Coreon.Models.SearchType.restore()
    Coreon.Views.Widgets.SearchView.restore()
    Coreon.Views.Widgets.LanguagesView.restore()
    Coreon.Views.Widgets.ClipboardView.restore()
    Coreon.Views.Widgets.ConceptMapView.restore()
    Coreon.Views.Widgets.TermListView.restore()
    Coreon.application = null

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-widgets"

  describe "initialize()", ->

    beforeEach ->
      sinon.stub Coreon.application, "repositorySettings"
      Coreon.application.repositorySettings.withArgs('widgets').returns width: 347

    afterEach ->
      Coreon.application.repositorySettings.restore()

    it "creates resize handle", ->
      expect( @view.$el).to.have ".ui-resizable-w"

    it "restores width from session", ->
      @view.initialize()
      expect( Coreon.application.repositorySettings ).to.be.calledWith("widgets")
      expect( @view.$el.width() ).to.equal 347

  describe "render()", ->

    it "is chainable", ->
      @view.render().should.equal @view

    it "removes subviews", ->
      subview = new Backbone.View
      subview.remove = sinon.spy()
      @view.subviews = [ subview ]
      @view.render()
      subview.remove.should.have.been.calledOnce
      @view.subviews.should.not.contain subview

    it "renders search view", ->
      @view.render()
      Coreon.Models.SearchType.should.have.been.calledOnce
      Coreon.Models.SearchType.should.have.been.calledWithNew
      Coreon.Views.Widgets.SearchView.should.have.been.calledOnce
      Coreon.Views.Widgets.SearchView.should.have.been.calledWithNew
      Coreon.Views.Widgets.SearchView.should.have.been.calledWith model: @searchType
      @search.render.should.have.been.calledOnce
      $.contains(@view.el, @search.el).should.be.true
      @view.subviews.should.contain @search

    it "renders languages view", ->
      @view.render()
      Coreon.Views.Widgets.LanguagesView.should.have.been.calledOnce
      Coreon.Views.Widgets.LanguagesView.should.have.been.calledWithNew
      #Coreon.Views.Widgets.LanguagesView.should.have.been.calledWith model: @searchType
      @languages.render.should.have.been.calledOnce
      $.contains(@view.el, @languages.el).should.be.true
      @view.subviews.should.contain @languages

    it "renders clipboard view", ->
      @view.render()
      Coreon.Views.Widgets.ClipboardView.should.have.been.calledOnce
      Coreon.Views.Widgets.ClipboardView.should.have.been.calledWithNew
      @clips.render.should.have.been.calledOnce
      $.contains(@view.el, @clips.el).should.be.true
      @view.subviews.should.contain @clips

    it "creates concept map view", ->
      @view.render()
      Coreon.Collections.ConceptMapNodes.should.have.been.calledOnce
      Coreon.Collections.ConceptMapNodes.should.have.been.calledWithNew
      Coreon.Views.Widgets.ConceptMapView.should.have.been.calledOnce
      Coreon.Views.Widgets.ConceptMapView.should.have.been.calledWithNew
      Coreon.Views.Widgets.ConceptMapView.should.have.been.calledWith
        model: @nodes
        hits: @hits
      @view.map.should.equal @map

    it "renders concept map view", ->
      @view.render()
      @map.render.should.have.been.calledOnce
      $.contains(@view.el, @map.el).should.be.true
      @view.subviews.should.contain @map

    it "renders term list view", ->
      @view.render()
      expect( Coreon.Views.Widgets.TermListView ).to.have.been.calledOnce
      expect( @terms.render ).to.have.been.calledOnce
      expect( $.contains @view.el, @terms.el ).to.be.true
      expect( @view.subviews ).to.contain @terms

  describe "resizing", ->

    beforeEach ->
      sinon.stub Coreon.application, "repositorySettings"
      Coreon.application.repositorySettings.withArgs('widgets').returns width: 347

      @clock = sinon.useFakeTimers()
      $("#konacha").append @view.render().$el
      @handle = @view.$(".ui-resizable-w")
      @handle.drag = (deltaX) =>
        @handle.simulate "mouseover"
        @handle.simulate "drag", dx: deltaX, moves: 1

    afterEach ->
      Coreon.application.repositorySettings.restore()
      @clock.restore()

    it "adjusts width when dragging resize handler", ->
      @view.$el.width 320
      @handle.drag -47
      @view.$el.width().should.equal 367

    it "syncs svg width", ->
      @view.$el.width 320
      @handle.drag -47
      @map.resize.should.have.been.calledOnce
      @map.resize.should.have.been.calledWith 367, null

    it "does not allow to reduce width below min width", ->
      @view.$el.width 320
      @handle.drag 300
      @view.$el.width().should.equal 240

    it "restores positioning after drag", ->
      @handle.drag 25
      @view.$el.css("top").should.equal "auto"
      @view.$el.css("left").should.equal "auto"

    it "stores width when finished", ->
      @view.$el.width 300
      @handle.drag -20
      @clock.tick 1000
      Coreon.application.repositorySettings.should.have.been.calledWith "widgets", width: 320
