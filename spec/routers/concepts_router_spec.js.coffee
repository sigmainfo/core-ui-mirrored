#= require spec_helper
#= require routers/concepts_router
#= require config/application

describe "Coreon.Routers.ConceptsRouter", ->
  
  beforeEach ->
    @xhr = sinon.useFakeXMLHttpRequest()
    @xhr.onCreate = (@request) =>

    @router = new Coreon.Routers.ConceptsRouter
      view: _(new Backbone.View).extend
        switch: (@screen) => @screen
        widgets:
          search:
            selector:
              hideHint: ->
      app: Coreon.application
    Backbone.history.start()

  afterEach ->
    @xhr.restore()
    Backbone.history.stop()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "initialize()", ->
    
    it "assigns view", ->
      view = new Backbone.View
      @router.initialize view
      @router.view.should.equal view

  xdescribe "search()", ->
    
    it "is routed", ->
      @router.search = sinon.spy()
      @router._bindRoutes()
      @router.navigate "concepts/search/description/movie", trigger: true
      @router.search.should.have.been.calledOnce
      @router.search.should.have.been.calledWith "description", "movie"

    it "is routed with target being optional", ->
      @router.search = sinon.spy()
      @router._bindRoutes()
      @router.navigate "concepts/search/movie", trigger: true
      @router.search.should.have.been.calledOnce
      @router.search.should.have.been.calledWith null, "movie"

    it "creates search", ->
      @router.search "terms", "gun"
      @screen.model.should.be.an.instanceof Coreon.Models.ConceptSearch 
      @screen.model.get("path").should.equal "concepts/search" 
      @screen.model.get("query").should.equal "gun" 
      @screen.model.get("target").should.equal "terms" 
      @screen.collection.should.be @router.collection

    xit "renders search results", ->
      @router.collection.get = sinon.stub()
      @router.collection.get.withArgs("5047774cd19879479b000523").returns _(new Backbone.Model).extend label: -> "Concept#1"
      @router.search q: "gun"
      @request.respond 200, {}, JSON.stringify
        hits: [
          {
            score: 1
            result:
              _id: "5047774cd19879479b000523"
          }
        ]
      @screen.should.be.an.instanceof Coreon.Views.Concepts.ConceptListView
      @screen.$el.should.have ".concept-list-item"

  xdescribe "show()", ->

    beforeEach ->
      sinon.stub Coreon.Models.Concept, "find"
      @concept = _( new Backbone.Model ).extend
        label: -> "concept #123"
      Coreon.Models.Concept.find.withArgs("123").returns @concept

    afterEach ->
      Coreon.Models.Concept.find.restore()
    
    it "is routed", ->
      @router.show = sinon.spy()
      @router._bindRoutes()
      @router.navigate "/concepts/507f191e810c19729de860ea", trigger: true
      @router.show.should.have.been.calledOnce
      @router.show.should.have.been.calledWith "507f191e810c19729de860ea"
      
    it "is not routed for ids not matching the format of a MongoDB ObjectId", ->
      @router.show = sinon.spy()
      @router._bindRoutes()
      @router.navigate "/concepts/1234", trigger: true
      @router.show.should.not.have.been.called
      
    it "renders concept details", ->
      @router.show "123"
      @screen.should.be.an.instanceof Coreon.Views.Concepts.ConceptView
      @screen.model.should.equal @concept

    it "updates selection", ->
      @router.app.hits.reset []
      @router.show "123"
      @router.app.hits.should.have.lengthOf 1
      @router.app.hits.at(0).get("result").should.equal @concept

  xdescribe "new()", ->

    beforeEach ->
      sinon.stub(Coreon.application.session.ability, "can").returns true

    afterEach ->
      Coreon.application.session.ability.can.restore()

    it "is routed", ->
      @router.new = sinon.spy()
      @router._bindRoutes()
      @router.navigate "/concepts/new", trigger: true
      @router.new.should.have.been.calledOnce

    it "is routed with additional params", ->
      @router.new = sinon.spy()
      @router._bindRoutes()
      @router.navigate "/concepts/new/terms/de/waffe", trigger: true
      @router.new.should.have.been.calledOnce
      @router.new.should.have.been.calledWith "de", "waffe"

    it "switches to new concept form", ->
      @router.new()
      @screen.should.be.an.instanceof Coreon.Views.Concepts.NewConceptView
      @screen.model.should.be.an.instanceof Coreon.Models.Concept
      @screen.model.isNew().should.be.true

    it "populates terms from params", ->
      @router.new "de", "waffe"
      @screen.model.terms().should.have.lengthOf 1
      @screen.model.terms().at(0).get("lang").should.equal "de"
      @screen.model.terms().at(0).get("value").should.equal "waffe"

    it "updates selection", ->
      @router.app.hits.reset []
      @router.new()
      @router.app.hits.should.have.lengthOf 1
      @router.app.hits.at(0).get("result").should.equal @screen.model

    it "redirects to start page when not able to create a concept", ->
      Coreon.application.session.ability.can
        .withArgs("create", Coreon.Models.Concept).returns false
      @router.new()
      console.log @screen
      @screen.should.be.an.instanceof Coreon.Views.Concepts.RootView
