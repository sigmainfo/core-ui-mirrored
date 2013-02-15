#= require spec_helper
#= require collections/concept_nodes

describe "Coreon.Collections.ConceptNodes", ->

  beforeEach ->
    sinon.stub Coreon.Models.Concept, "find"
    @collection = new Coreon.Collections.ConceptNodes

  afterEach ->
    @collection.stopListening()
    Coreon.Models.Concept.find.restore()

  it "is a Treegraph collection", ->
    @collection.should.be.an.instanceof Coreon.Collections.Treegraph
    @collection.options.should.have.deep.property "digraph.in", "super_concept_ids"
    @collection.options.should.have.deep.property "digraph.out", "sub_concept_ids"

  it "creates ConceptNode models", ->
    @collection.add id: "node"
    @collection.get("node").should.be.an.instanceof Coreon.Models.ConceptNode

  describe "initialize()", ->

    context "when connected to hits", ->
    
      beforeEach ->
        @hits = new Backbone.Collection

      it "calls super", ->
        sinon.stub Coreon.Collections.Treegraph::, "initialize"
        try
          @collection.initialize()
          Coreon.Collections.Treegraph::initialize.should.have.been.calledOnce
        finally
          Coreon.Collections.Treegraph::initialize.restore()
      
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

  describe "add()", ->

    beforeEach ->
      @node = new @collection.model id: "node"
    
    context "with children expanded", ->

      beforeEach ->
        @node.set "childrenExpanded", true, silent: true

      it "adds children", ->
        @node.set "sub_concept_ids", ["child_1", "child_2"], silent: true
        @collection.add @node
        @collection.should.have.length 3 
        expect( @collection.get "child_1" ).to.exist
        expect( @collection.get "child_2" ).to.exist

    context "with children collapsed", ->

      beforeEach ->
        @node.set "childrenExpanded", false, silent: true

      it "does not add children", ->
        @node.set "sub_concept_ids", ["child_1", "child_2"], silent: true
        @collection.add @node
        @collection.should.have.length 1

    context "with parents expanded", ->
      
      beforeEach ->
        @node.set "parentsExpanded", true, silent: true

      it "adds parents", ->
        @node.set "super_concept_ids", ["parent_1", "parent_2"], silent: true
        @collection.add @node
        @collection.should.have.length 3 
        expect( @collection.get "parent_1" ).to.exist
        expect( @collection.get "parent_2" ).to.exist

      it "expands children of newly added parents", ->
        @node.set "super_concept_ids", ["parent"], silent: true
        @collection.add @node
        @collection.get("parent").get("childrenExpanded").should.be.true

      it "expands children of existing parents", ->
        @node.set "super_concept_ids", ["parent"], silent: true
        @collection.reset [ id: "parent", sub_concept_ids: ["sibling_1", "sibling_2"] ], silent: true
        @collection.add @node
        @collection.get("parent").get("childrenExpanded").should.be.true
        @collection.should.have.length 4
        expect( @collection.get "sibling_1" ).to.exist
        expect( @collection.get "sibling_2" ).to.exist

    context "with parents collapsed", ->
      
      beforeEach ->
        @node.set "parentsExpanded", false, silent: true

      it "does not add parents", ->
        @node.set "super_concept_ids", ["parent_1", "parent_2"], silent: true
        @collection.add @node
        @collection.should.have.length 1
  
  describe "remove()", ->

    beforeEach ->
      @node = new @collection.model id: "node"
      @collection.reset [ @node ], silent: true
      
    it "removes children", ->
      @node.set "sub_concept_ids", [ "child_1", "child_2" ], silent: true
      @collection.add [ {id: "child_1"}, {id: "child_2"} ], silent: true
      @collection.remove @node 
      @collection.should.have.length 0

    it "removes children of children", ->
      @node.set "sub_concept_ids", [ "child" ], silent: true
      child = id: "child", sub_concept_ids: [ id: "child_of_child" ]
      @collection.add [
        { id: "child", sub_concept_ids: [ "child_of_child" ] }
        { id: "child_of_child" }
      ], silent: true
      @collection.remove @node 
      @collection.should.have.length 0

    it "keeps nodes that have another parent", ->
      
      

  describe "on change", ->

    beforeEach ->
      @node = new @collection.model id: "node"
      @collection.reset [ @node ], silent: true

    context "sub_concept_ids", ->
      
      context "with children expanded", ->

        beforeEach ->
          @node.set "childrenExpanded", true, silent: true
        
        it "adds children", ->
          @node.set "sub_concept_ids", ["child_1", "child_2"]
          @collection.should.have.length 3 
          expect( @collection.get "child_1" ).to.exist
          expect( @collection.get "child_2" ).to.exist
        
        it "does not create duplicates", ->
          @node.set "sub_concept_ids", ["node"]
          @collection.should.have.length 1 

      context "with children collapsed", ->

        beforeEach ->
          @node.set "childrenExpanded", false, silent: true

        it "does not add children", ->
          @node.set "sub_concept_ids", ["child_1", "child_2"]
          @collection.should.have.length 1

    context "super_concept_ids", ->

      context "with parents expanded", ->
        
        beforeEach ->
          @node.set "parentsExpanded", true, silent: true

        it "adds parents", ->
          @node.set "super_concept_ids", ["parent_1", "parent_2"]
          @collection.should.have.length 3 
          expect( @collection.get "parent_1" ).to.exist
          expect( @collection.get "parent_2" ).to.exist

        it "expands children of newly added parents", ->
          @node.set "super_concept_ids", ["parent"]
          @collection.get("parent").get("childrenExpanded").should.be.true

        it "expands children of existing parents", ->
          parent = id: "parent", sub_concept_ids: ["sibling_1", "sibling_2"]
          @collection.reset [ parent, @node ], silent: true
          @node.set "super_concept_ids", ["parent"]
          @collection.get("parent").get("childrenExpanded").should.be.true
          @collection.should.have.length 4
          expect( @collection.get "sibling_1" ).to.exist
          expect( @collection.get "sibling_2" ).to.exist


      context "with parents collapsed", ->
        
        beforeEach ->
          @node.set "parentsExpanded", false, silent: true

        it "does not add parents", ->
          @node.set "super_concept_ids", ["parent_1", "parent_2"]
          @collection.should.have.length 1

    context "childrenExpanded", ->

      beforeEach ->
        @node.set sub_concept_ids: ["child_1", "child_2"]
        @collection.reset [ @node ]

      context "set to true", ->
        
        beforeEach ->
          @node.set "childrenExpanded", false, silent: true
        
        it "adds children", ->
          @node.set "childrenExpanded", true
          @collection.should.have.length 3
          expect( @collection.get "child_1" ).to.exist
          expect( @collection.get "child_2" ).to.exist

      context "set to false", ->
        
        beforeEach ->
          @node.set "childrenExpanded", true, silent: true
        
        xit "removes children", ->
          @collection.add [ {id: "child_1"}, {id: "child_2"} ], silent: true
          @node.set "childrenExpanded", false
          @collection.should.have.length 1

        it "keeps children that have other parent"
        it "removes children of children"
        it "keeps children of children that have other parents"

    context "parentsExpanded", ->
     
      beforeEach ->
        @node.set super_concept_ids: ["parent_1", "parent_2"]
        @collection.reset [ @node ], silent: true

      context "set to true", ->
        
        beforeEach ->
          @node.set "parentsExpanded", false, silent: true
        
        it "adds parents", ->
          @node.set "parentsExpanded", true
          @collection.should.have.length 3
          expect( @collection.get "parent_1" ).to.exist
          expect( @collection.get "parent_2" ).to.exist

        it "expands children of newly added parents", ->
          @node.set "parentsExpanded", true
          @collection.get("parent_1").get("childrenExpanded").should.be.true
          @collection.get("parent_2").get("childrenExpanded").should.be.true

        it "expands children of existing parents", ->
          parent = id: "parent_1", sub_concept_ids: ["sibling_1", "sibling_2"]
          @collection.reset [ parent, @node ], silent: true
          @node.set "parentsExpanded", true
          @collection.get("parent_1").get("childrenExpanded").should.be.true
          @collection.should.have.length 5
          expect( @collection.get "sibling_1" ).to.exist
          expect( @collection.get "sibling_2" ).to.exist

      context "set to false", ->
        
        beforeEach ->
          @node.set "parentsExpanded", true
          
        it "removes children"
        it "keeps children that have other parent"
        it "removes children of children"
        it "keeps children of children that have other parents"


