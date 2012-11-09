#= require spec_helper
#= require routers/concepts_router
#= require config/application

describe "Coreon.Routers.ConceptsRouter", ->
  
  beforeEach ->
    Coreon.application = new Coreon.Application
    @xhr = sinon.useFakeXMLHttpRequest()
    @xhr.onCreate = (@request) =>

    @router = new Coreon.Routers.ConceptsRouter
      collection: _(new Backbone.Collection).extend
        addOrUpdate: ->
      view: _(new Backbone.View).extend
        switch: (@screen) => @screen
        widgets:
          search:
            selector:
              hideHint: ->

  afterEach ->
    Coreon.application.destroy()
    @xhr.restore()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "#initialize", ->
    
    it "takes options", ->
      concepts = new Backbone.Collection
      view = new Backbone.View
      @router.initialize
        collection: concepts
        view: view
      @router.collection.should.equal concepts
      @router.view.should.equal view

  #TODO: make this #index? 
  describe "#search", ->
    
    it "is routed", ->
      @router.routes["concepts/search"].should.equal "search"

    it "creates search", ->
      @router.search q: "gun"
      @screen.model.should.be.an.instanceof Coreon.Models.Search 
      @screen.model.get("path").should.equal "concepts/search" 
      @screen.model.get("query").should.equal "gun" 
      @screen.collection.should.be @router.collection

    it "renders search results", ->
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

  describe "#show", ->

    beforeEach ->
      sinon.stub Coreon.Models.Concept, "find"
      @concept = _( new Backbone.Model ).extend
        label: -> "concept #123"

    afterEach ->
      Coreon.Models.Concept.find.restore()
    
    it "is routed", ->
      @router.routes["concepts/:id"].should.equal "show"
      
    it "renders concept details", ->
      Coreon.Models.Concept.find.withArgs("123").returns @concept
      @router.show "123"
      @screen.should.be.an.instanceof Coreon.Views.Concepts.ConceptView
      @screen.model.should.equal @concept