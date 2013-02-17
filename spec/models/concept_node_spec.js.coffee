#= require spec_helper
#= require models/concept_node

describe "Coreon.Models.ConceptNode", ->

  beforeEach ->
    sinon.stub Coreon.Models.Concept, "find"
    @node = new Coreon.Models.ConceptNode

  afterEach ->
    @node.stopListening()
    Coreon.Models.Concept.find.restore()

  it "should be a Backbone model", ->
    @node.should.be.an.instanceof Backbone.Model

  describe "initialize()", ->

    it "assigns concept from options when given", ->
      concept = new Backbone.Model id: "123"
      @node.initialize {}, concept: concept
      @node.concept.should.equal concept

    it "assigns concept from id attribute", ->
      concept = new Backbone.Model id: "123"
      Coreon.Models.Concept.find.withArgs("123").returns concept
      @node.initialize id: "123"
      @node.concept.should.equal concept

  describe "attributes", ->
  
    describe "hit", ->

      it "defaults to null", ->
        expect( @node.get "hit" ).to.be.null

    describe "expandedIn", ->

      it "defaults to false", ->
        expect( @node.get "expandedIn" ).to.be.false
        
    describe "expandedOut", ->
    
      it "defaults to false", ->
        expect( @node.get "expandedOut" ).to.be.false

    context "derived from concept", ->

      beforeEach ->
        @concept = new Backbone.Model id: 123
        @node.initialize {}, concept: @concept
      
      it "passes thru attribute from concept", ->
        @concept.set "label", "concept #123", silent: true
        @node.get("label").should.equal "concept #123"

      it "triggers concept change events", ->
        spy = sinon.spy()
        @node.on "all", spy
        @concept.set "foo", "bar", myOption: true
        spy.should.have.been.calledTwice
        spy.firstCall.should.have.been.calledWith "change:foo", @node, "bar", myOption: true
        spy.secondCall.should.have.been.calledWith "change", @node, myOption: true

      it "does not trigger other concept events", ->
        spy = sinon.spy()
        @node.on "all", spy
        @concept.destroy()
        spy.should.not.have.been.called
