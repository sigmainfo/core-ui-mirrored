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
  
    it "sets concept from id", ->
      concept = new Backbone.Model
      Coreon.Models.Concept.find.withArgs("concept").returns concept
      @node.id = "concept"
      @node.initialize()
      @node.get("concept").should.equal concept
      
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

    describe "subnodeIds", ->

      context "when expanded", ->

        beforeEach ->
          @node.set "expandedOut", true, silent: true

        it "defaults to an empty array", ->
          @node.get("subnodeIds").should.be.an.instanceof Array
          @node.get("subnodeIds").should.have.length 0

        it "keeps a copy of the sub_concept_ids", ->
          @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ]
          @node.get("subnodeIds").should.eql [ "subnode_1", "subnode_2" ]
          @node.get("subnodeIds").should.not.equal @node.get("sub_concept_ids")

      context "when collapsed", ->

        beforeEach ->
          @node.set "expandedOut", false, silent: true

        it "always returns empty array", ->
          @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ]
          @node.get("subnodeIds").should.have.length 0

      context "toggle state", ->
        
        it "returns sub_concept_ids after expanding", ->
          @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ], silent: true
          @node.get("subnodeIds").should.have.length 0
          @node.set "expandedOut", true
          @node.get("subnodeIds").should.have.length 2

        it "returns empty set after collapsing", ->
          @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ], silent: true
          @node.set "expandedOut", true
          @node.get("subnodeIds").should.have.length 2
          @node.set "expandedOut", false
          @node.get("subnodeIds").should.have.length 0
          
    describe "subnodeIds", ->

      context "when expanded", ->

        beforeEach ->
          @node.set "expandedOut", true, silent: true

        it "defaults to an empty array", ->
          @node.get("subnodeIds").should.be.an.instanceof Array
          @node.get("subnodeIds").should.have.length 0

        it "keeps a copy of the sub_concept_ids", ->
          @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ]
          @node.get("subnodeIds").should.eql [ "subnode_1", "subnode_2" ]
          @node.get("subnodeIds").should.not.equal @node.get("sub_concept_ids")

        it "sets value on init", ->
          node = new Coreon.Models.ConceptNode
            sub_concept_ids: [ "subnode" ]
            expandedOut: true
          node.get("subnodeIds").should.have.deep.property "[0]", "subnode"

      context "when collapsed", ->

        beforeEach ->
          @node.set "expandedOut", false, silent: true

        it "always returns empty array", ->
          @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ]
          @node.get("subnodeIds").should.have.length 0

      context "toggle state", ->
        
        it "returns sub_concept_ids after expanding", ->
          @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ], silent: true
          @node.get("subnodeIds").should.have.length 0
          @node.set "expandedOut", true
          @node.get("subnodeIds").should.have.length 2

        it "returns empty set after collapsing", ->
          @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ], silent: true
          @node.set "expandedOut", true
          @node.get("subnodeIds").should.have.length 2
          @node.set "expandedOut", false
          @node.get("subnodeIds").should.have.length 0

    describe "supernodeIds", ->

      context "when expanded", ->

        beforeEach ->
          @node.set "expandedIn", true, silent: true

        it "defaults to an empty array", ->
          @node.get("supernodeIds").should.be.an.instanceof Array
          @node.get("supernodeIds").should.have.length 0

        it "keeps a copy of the super_concept_ids", ->
          @node.set "super_concept_ids", [ "supernode_1", "supernode_2" ]
          @node.get("supernodeIds").should.eql [ "supernode_1", "supernode_2" ]
          @node.get("supernodeIds").should.not.equal @node.get("super_concept_ids")

        it "sets value on init", ->
          node = new Coreon.Models.ConceptNode
            super_concept_ids: [ "supernode" ]
            expandedIn: true
          node.get("supernodeIds").should.have.deep.property "[0]", "supernode"

      context "when collapsed", ->

        beforeEach ->
          @node.set "expandedIn", false, silent: true

        it "always returns empty array", ->
          @node.set "super_concept_ids", [ "supernode_1", "supernode_2" ]
          @node.get("supernodeIds").should.have.length 0

      context "toggle state", ->
        
        it "returns super_concept_ids after expanding", ->
          @node.set "super_concept_ids", [ "supernode_1", "supernode_2" ], silent: true
          @node.get("supernodeIds").should.have.length 0
          @node.set "expandedIn", true
          @node.get("supernodeIds").should.have.length 2

        it "returns empty set after collapsing", ->
          @node.set "super_concept_ids", [ "supernode_1", "supernode_2" ], silent: true
          @node.set "expandedIn", true
          @node.get("supernodeIds").should.have.length 2
          @node.set "expandedIn", false
          @node.get("supernodeIds").should.have.length 0
        
        
    context "derived from concept", ->

      beforeEach ->
        @concept = new Backbone.Model

      it "passes thru attribute from concept", ->
        @node.set "concept", @concept
        @concept.set "label", "concept #123", silent: true
        @node.get("label").should.equal "concept #123"

      it "triggers concept change events", ->
        @node.set "concept", @concept
        spy = sinon.spy()
        @node.on "all", spy
        @concept.set "foo", "bar", myOption: true
        spy.should.have.been.calledTwice
        spy.firstCall.should.have.been.calledWith "change:foo", @node, "bar", myOption: true
        spy.secondCall.should.have.been.calledWith "change", @node, myOption: true

      it "does not trigger other concept events", ->
        @node.set "concept", @concept
        spy = sinon.spy()
        @node.on "all", spy
        @concept.destroy()
        spy.should.not.have.been.called

      it "updates id from concept", ->
        @concept.set "_id", "abcde"
        @node.set "concept", @concept
        @node.id.should.equal "abcde"
        
      it "updates id together with concept", ->
        @node.set "concept", @concept
        @concept.set "_id", "abcde"
        @node.id.should.equal "abcde"
        

      it "falls back to cid when updating id from concept", ->
        @concept.cid = "c123"
        @node.set "concept", @concept
        @node.id.should.equal "c123"
