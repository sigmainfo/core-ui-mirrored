#= require spec_helper
#= require routers/search_router
#= require config/application

describe "Coreon.Routers.SearchRouter", ->
  
  beforeEach ->
    $("#konacha").append('<div id="coreon-main">')
    @router = new Coreon.Routers.SearchRouter
      view: _(new Backbone.View(el: $("#konacha"))).extend
        switch: (@screen) => @screen.render() 
      # concepts: Coreon.application.concepts
      # app: Coreon.application

    # @router.view.widgets =
    #   search:
    #     selector:
    #       hideHint: sinon.spy()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "initialize()", ->
    
    it "assigns view", ->
      view = new Backbone.View
      @router.initialize view
      @router.view.should.equal view

  describe "search()", ->

    beforeEach ->
      # @xhr = sinon.useFakeXMLHttpRequest()
      # @xhr.onCreate = (@request) =>

    afterEach ->
      # @xhr.restore()

    it "is routed", ->
      @router.search = sinon.spy()
      @router._bindRoutes()
      @router.navigate "51bedb0cd19879112b000004/concepts/definition/search/movie", trigger: true
      @router.search.should.have.been.calledOnce
      @router.search.should.have.been.calledWith "description", "movie"

    it "renders search results", ->
      @router.search "poet"
      @router.searchResultsView.should.be.an.instanceof Coreon.Views.Search.SearchResultsView
      @screen.should.equal @router.searchResultsView
      @router.searchResultsView.$el.should.have ".search-results-terms"
      
    it "creates term search", ->
      @router.search "poet"
      @router.searchResultsView.terms.model.should.be.an.instanceof Coreon.Models.Search
      @router.searchResultsView.terms.model.get("path").should.equal "terms/search"
      @router.searchResultsView.terms.model.get("query").should.equal "poet"

    it "creates concepts search", ->
      @router.search "poet"
      @router.searchResultsView.concepts.model.should.be.an.instanceof Coreon.Models.ConceptSearch
      @router.searchResultsView.concepts.model.get("path").should.equal "concepts/search"
      @router.searchResultsView.concepts.model.get("query").should.equal "poet"

    it "creates taxonomy search", ->
      @router.search "poet"
      @router.searchResultsView.tnodes.model.should.be.an.instanceof Coreon.Models.Search
      @router.searchResultsView.tnodes.model.get("path").should.equal "taxonomy_nodes/search"
      @router.searchResultsView.tnodes.model.get("query").should.equal "poet"

    it "fetches search results", ->
      Coreon.application.sync = sinon.stub().returns done: ->
      @router.search "poet"
      Coreon.application.sync.should.have.been.calledWith "read", @router.searchResultsView.terms.model
      Coreon.application.sync.should.have.been.calledWith "read", @router.searchResultsView.concepts.model
      Coreon.application.sync.should.have.been.calledWith "read", @router.searchResultsView.tnodes.model

    it "decodes queries", ->
      @router.search "h%C3%A4schen"
      @router.searchResultsView.terms.model.get("query").should.equal "häschen"
      @router.searchResultsView.concepts.model.get("query").should.equal "häschen"
      @router.searchResultsView.tnodes.model.get("query").should.equal "häschen"
      
