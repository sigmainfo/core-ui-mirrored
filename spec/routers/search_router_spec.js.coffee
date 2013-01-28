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
      app: Coreon.application

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
      @router.routes.should.have.property "search/:query", "search"

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
      @router.searchResultsView.concepts.model.should.be.an.instanceof Coreon.Models.Search
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

    context "done", ->
      
      beforeEach ->
        sinon.stub(Coreon.Views.Search, "SearchResultsView").returns render: ->

      afterEach ->
        Coreon.Views.Search.SearchResultsView.restore()
        
      it "updates concepts from results", ->
        @router.search "poet"
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
        concept = Coreon.Models.Concept.find "1234"
        concept.get("properties").should.eql [{key: "label", value: "poet"}]
        concept.get("super_concept_ids").should.eql ["5047774cd19879479b000523", "5047774cd19879479b00002b"]

      it "updates current hits", ->
        @router.app.hits.reset = sinon.spy()
        @router.search "poet"
        @request.respond 200, {}, JSON.stringify
          hits: [
            {
              score: 1.56
              result:
                _id: "1234"
            }
          ]
        @router.app.hits.reset.should.have.been.calledWith [ { id: "1234", score: 1.56 }]
       

    it "restores search input", ->
      spy = sinon.spy()
      sinon.stub(@router.view, "$").withArgs("input#coreon-search-query").returns val: spy
      @router.search "poet"
      @router.view.widgets.search.selector.hideHint.should.have.been.calledOnce
      spy.should.have.been.calledWith "poet"
