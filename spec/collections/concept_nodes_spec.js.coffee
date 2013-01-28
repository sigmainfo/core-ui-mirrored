#= require spec_helper
#= require collections/concept_nodes

describe "Coreon.Collections.ConceptNodes", ->

  beforeEach ->
    sinon.stub Coreon.Models.Concept, "find"
    @collection = new Coreon.Collections.ConceptNodes

  afterEach ->
    @collection.stopListening()
    Coreon.Models.Concept.find.restore()

  it "is a backbone collection", ->
    @collection.should.be.an.instanceof Backbone.Collection

  it "creates ConceptNode models", ->
    @collection.add id: "node"
    @collection.get("node").should.be.an.instanceof Coreon.Models.ConceptNode

  it "includes digraph functionality", ->
    Coreon.Collections.ConceptNodes::tree.should.equal Coreon.Modules.Digraph.tree

  describe "initialize()", ->

    it "initializes digraph options", ->
      @collection.initializeDigraph = sinon.spy()
      @collection.initialize()
      @collection.initializeDigraph.should.have.been.calledOnce

    context "when connected to hits", ->
    
      beforeEach ->
        @hits = new Backbone.Collection
      
      it "assigns hits from options", ->
        @collection.initialize [], hits: @hits
        @collection.hits.should.equal @hits
    
      it "resets from hits when given", ->
        models = [ id: "384796" ]
        @hits.models = models
        @collection.resetFromHits = sinon.spy() 
        @collection.initialize [], hits: @hits
        @collection.resetFromHits.should.have.been.calledOnce 
        @collection.resetFromHits.should.have.been.calledWith models

  describe "resetFromHits()", ->

    it "is triggered on hits reset", ->
      models = [ new Backbone.Model ]
      hits = new Backbone.Collection models
      @collection.resetFromHits = sinon.spy()
      @collection.initialize [], hits: hits
      @collection.resetFromHits.reset()
      hits.trigger "reset"
      @collection.resetFromHits.should.have.been.calledOnce
      @collection.resetFromHits.should.have.been.calledWith models

    it "adds nodes for hits", ->
      hit = id: "123"
      @collection.resetFromHits [ hit ]
      node = @collection.get "123"
      expect( node ).to.exist
      node.get("hit").should.equal hit

    it "removes nodes from hits", ->
      @collection.reset [ id: "old" ], silent: true 
      hit = id: "123"
      @collection.resetFromHits [ hit ]
      @collection.should.have.length 1
      expect(@collection.get "old").not.to.exist

    it "updates attrs", ->
      @collection.reset [ id: "123" ], silent: true
      hit = id: "123"
      @collection.resetFromHits [ hit ]
      @collection.get("123").get("hit").should.equal hit

    it "creates fully expanded nodes", ->
      @collection.resetFromHits [ id: "123" ]
      node = @collection.get "123"
      node.get("childrenExpanded").should.be.true
      node.get("parentsExpanded").should.be.true
