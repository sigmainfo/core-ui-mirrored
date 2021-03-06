#= require spec_helper
#= require views/widgets/widgets_view

describe "Coreon.Views.Widgets.WidgetsView", ->

  beforeEach ->
    Coreon.application = new Backbone.Model
    Coreon.application.cacheId =-> "face42"
    Coreon.application.repositorySettings = -> new Backbone.Model
    Coreon.application.sourceLang = -> null

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

    @view = new Coreon.Views.Widgets.WidgetsView
      model: new Backbone.Collection
        hits: new Backbone.Collection

  afterEach ->
    Coreon.Models.SearchType.restore()
    Coreon.Views.Widgets.SearchView.restore()
    Coreon.Views.Widgets.LanguagesView.restore()
    Coreon.application = null

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-widgets"

  describe "#initialize()", ->

    beforeEach ->
      sinon.stub Coreon.application, "repositorySettings"
      Coreon.application.repositorySettings
        .withArgs('widgets').returns width: 347

    afterEach ->
      Coreon.application.repositorySettings.restore()

  describe "#render()", ->

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
      Coreon.Views.Widgets.SearchView.should.have.been.calledWith
        model: @searchType
      @search.render.should.have.been.calledOnce
      $.contains(@view.el, @search.el).should.be.true
      @view.subviews.should.contain @search

    it "renders languages view", ->
      @view.render()
      Coreon.Views.Widgets.LanguagesView.should.have.been.calledOnce
      Coreon.Views.Widgets.LanguagesView.should.have.been.calledWithNew
      @languages.render.should.have.been.calledOnce
      $.contains(@view.el, @languages.el).should.be.true
      @view.subviews.should.contain @languages
