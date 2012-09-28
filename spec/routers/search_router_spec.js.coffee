#= require spec_helper
#= require routers/search_router
#= require config/application

describe "Coreon.Routers.SearchRouter", ->
  
  beforeEach ->
    Coreon.application = new Coreon.Application

    $("#konacha").append('<div id="coreon-main">')
    @router = new Coreon.Routers.SearchRouter
      view: _(new Backbone.View(el: $("#konacha"))).extend
        switch: (@screen) => @screen.render() 
      concepts: Coreon.application.concepts

    @router.view.widgets =
      search:
        selector:
          hideHint: sinon.spy()

  afterEach ->
    Coreon.application.destroy()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "#initialize", ->
    
    it "stores references", ->
      @router.initialize view: "myView", concepts: "concepts"
      @router.view.should.equal "myView"
      @router.concepts.should.equal "concepts"
    

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
      @router.searchResultsView.should.be.an.instanceof Coreon.Views.Search.SearchResultsView
      @screen.should.equal @router.searchResultsView
      @router.searchResultsView.$el.should.have ".search-results-terms"
      
    it "creates term search", ->
      @router.search q: "poet"
      @router.searchResultsView.terms.model.should.be.an.instanceof Coreon.Models.Search
      @router.searchResultsView.terms.model.get("path").should.equal "terms/search"
      @router.searchResultsView.terms.model.get("query").should.equal "poet"

    it "creates concepts search", ->
      @router.search q: "poet"
      @router.searchResultsView.concepts.model.should.be.an.instanceof Coreon.Models.Search
      @router.searchResultsView.concepts.model.get("path").should.equal "concepts/search"
      @router.searchResultsView.concepts.model.get("query").should.equal "poet"

    it "creates taxonomy search", ->
      @router.search q: "poet"
      @router.searchResultsView.tnodes.model.should.be.an.instanceof Coreon.Models.Search
      @router.searchResultsView.tnodes.model.get("path").should.equal "tnodes/search"
      @router.searchResultsView.tnodes.model.get("query").should.equal "poet"

    it "fetches search results", ->
      Coreon.application.sync = sinon.stub().returns done: ->
      @router.search q: "poet"
      Coreon.application.sync.should.have.been.calledWith "read", @router.searchResultsView.terms.model
      Coreon.application.sync.should.have.been.calledWith "read", @router.searchResultsView.concepts.model
      Coreon.application.sync.should.have.been.calledWith "read", @router.searchResultsView.tnodes.model

    it "updates concepts from results", ->
      sinon.stub(Coreon.Views.Search, "SearchResultsView").returns render: ->
      try
        @router.search q: "poet"
        @request.respond 200, {}, JSON.stringify
          hits: [
            {
              score: 1.56
              result:
                _id: "1234"
                properties: [
                  { key: "label", value: "poet" }
                ]
                super_concept_ids: [
                  "5047774cd19879479b000523"
                  "5047774cd19879479b00002b"
                ]
            }
          ]
        concept = Coreon.application.concepts.get "1234"
        expect(concept).to.be.an.instanceof Coreon.Models.Concept
        concept.get("properties").should.eql [{key: "label", value: "poet"}]
        concept.get("super_concept_ids").should.eql ["5047774cd19879479b000523", "5047774cd19879479b00002b"]
      finally
        Coreon.Views.Search.SearchResultsView.restore()

    it "restores search input", ->
      spy = sinon.spy()
      sinon.stub(@router.view, "$").withArgs("input#coreon-search-query").returns val: spy
      @router.search q: "poet"
      @router.view.widgets.search.selector.hideHint.should.have.been.calledOnce
      spy.should.have.been.calledWith "poet"
