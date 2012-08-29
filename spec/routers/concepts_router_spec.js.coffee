#= require spec_helper
#= require routers/concepts_router

describe "Coreon.Routers.ConceptsRouter", ->
  
  beforeEach ->
    @router = new Coreon.Routers.ConceptsRouter new Backbone.Collection

  afterEach ->
    Backbone.history = null
      
  it "is a Backbone router", ->
    @router.should.be.an.instanceOf Backbone.Router

  describe "#initialize", ->
    
    it "stores reference to concepts  ", ->
      concepts = new Backbone.Collection
      @router.initialize concepts
      @router.collection.should.equal concepts

  describe "#search", ->

    it "is routed", ->
      @router.routes["concepts/search"].should.equal "search"

    it "fetches relevant concepts", ->
      @router.collection.fetch = sinon.spy()
      @router.search q: "dead man"
      @router.collection.fetch.should.have.been.calledWith 
        data:
          "search[query]": "dead man"
