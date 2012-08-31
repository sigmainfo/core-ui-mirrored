#= require spec_helper
#= require routers/search_router

describe "Coreon.Routers.SearchRouter", ->
  
  beforeEach ->
    Coreon.application =
      sync: ->

    $("#konacha").append('<div id="coreon-main">')
    @router = new Coreon.Routers.SearchRouter new Backbone.View(el: $("#konacha"))

  afterEach ->
    Coreon.application = null

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "#initialize", ->
    
    it "stores view", ->
      @router.initialize "myView"
      @router.view.should.equal "myView"
    

  describe "#search", ->

    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (@request) =>

    afterEach ->
      @xhr.restore()

    it "is routed", ->
      @router.routes["search"].should.equal "search"

    it "renders search results", ->
      @router.search q: "poet"
      @router.searchResultsView.should.be.an.instanceof Coreon.Views.Main.SearchResultsView
      @router.searchResultsView.$el.should.have.id "coreon-main"
      @router.searchResultsView.$el.should.have ".search-results-terms"
      
    it "creates term search", ->
      @router.search q: "poet"
      @router.searchResultsView.terms.model.should.be.an.instanceof Coreon.Models.Search
      @router.searchResultsView.terms.model.get("path").should.equal "terms/search"
      @router.searchResultsView.terms.model.get("params")["search[query]"].should.equal "poet"

    it "creates concepts search", ->
      @router.search q: "poet"
      @router.searchResultsView.concepts.model.should.be.an.instanceof Coreon.Models.Search
      @router.searchResultsView.concepts.model.get("path").should.equal "concepts/search"
      @router.searchResultsView.concepts.model.get("params")["search[query]"].should.equal "poet"

    it "fetches search results", ->
      Coreon.application.sync = sinon.spy()
      @router.search q: "poet"
      Coreon.application.sync.should.have.been.calledWith "read", @router.searchResultsView.terms.model
      Coreon.application.sync.should.have.been.calledWith "read", @router.searchResultsView.concepts.model

