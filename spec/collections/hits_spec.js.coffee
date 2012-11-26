#= require spec_helper
#= require collections/hits

describe "Coreon.Collections.Hits", ->

  beforeEach ->
    sinon.stub Coreon.Models.Concept, "find"
    @concepts = {}
    @createConcept = (id, attrs = {}) ->
      attrs._id = id
      @concepts[id] = new Coreon.Models.Concept attrs
      Coreon.Models.Concept.find.withArgs(id).returns @concepts[id]
      @concepts[id]
    @concept = @createConcept "799"
    @hits = new Coreon.Collections.Hits
    @hit  = new Coreon.Models.Hit id: "799"

  afterEach ->
    Coreon.Models.Concept.find.restore()

  it "is a Backbone collection", ->
    @hits.should.be.an.instanceof Backbone.Collection

  it "uses Hit model", ->
    @hits.model.should.equal Coreon.Models.Hit

  describe "update()", ->

    beforeEach ->
      @spy = sinon.spy()
      
    it "adds missing", ->
      @hit.on "add", @spy
      @hits.update [ @hit ]
      @spy.should.have.been.calledOnce
      @hits.models.should.eql [ @hit ]

    it "removes dropped", ->
      @hits.add [ @hit ], silent: true
      @hit.on "remove", @spy
      @hits.update []
      @spy.should.have.been.calledOnce
      @hits.models.should.eql []

    it "keeps existing", ->
      @hits.add [ @hit ], silent: true
      @hit.on "add remove", @spy
      @hits.update [ @hit ]
      @spy.should.not.have.been.called
      @hits.models.should.eql [ @hit ]

    context "hit:update", ->

      it "triggers hit:update on collection", ->
        @hits.on "hit:update", @spy
        @hits.update [ @hit ]
        @spy.should.have.been.calledOnce
        @spy.should.have.been.calledWith @hits, index: 0

      it "does not trigger hit:update when not changed", ->
        @hits.update [ @hit ], silent: true
        @hits.on "hit:update", @spy
        @hits.update [ @hit ]
        @spy.should.not.have.been.called

      it "does not trigger hit:update when silent is true", ->
        @hits.on "hit:add hit:remove hit:update", @spy
        @hits.update [ @hit ], silent: true
        @hits.update [], silent: true
        @spy.should.not.have.been.called

    context "events on related concept", ->

      it "triggers hit:add", ->
        @concept.on "hit:add", @spy
        @hits.update [ @hit ]
        @spy.should.have.been.calledOnce
        @spy.should.have.been.calledWith @hit, @hits, index: 0

      it "triggers hit:remove", ->
        @hits.update [ @hit ], silent: true
        @concept.on "hit:remove", @spy
        @hits.update []
        @spy.should.have.been.calledOnce
        @spy.should.have.been.calledWith @hit, @hits, index: 0

  describe "nodes()", ->

    context "creating nodes", ->

      it "returns empty hash when there are no hits", ->
        @hits.nodes().should.be.an "object"
        @hits.nodes().should.be.empty
 

      it "creates nodes for hits", ->
        hit1 = @createConcept "hit1"
        hit2 = @createConcept "hit2"
        @hits.update [
          { id: "hit1" }
          { id: "hit2" }
        ]
        @hits.nodes().should.have.property("hit1").with.property "concept", hit1
        @hits.nodes().should.have.property("hit2").with.property "concept", hit2

      it "creates nodes for parents", ->
        parent1 = @createConcept "parent1"
        parent2 = @createConcept "parent2"
        parent3 = @createConcept "parent3"
        hit1 = @createConcept "hit1", super_concept_ids: [ "parent1" ]
        hit2 = @createConcept "hit2", super_concept_ids: [ "parent2", "parent3" ]
        @hits.update [
          { id: "hit1" }
          { id: "hit2" }
        ]
        @hits.nodes().should.have.property("parent1").with.property "concept", parent1
        @hits.nodes().should.have.property("parent2").with.property "concept", parent2
        @hits.nodes().should.have.property("parent1").with.property "concept", parent1

      it "creates nodes for siblings", ->
        hit = @createConcept "hit", super_concept_ids: [ "parent" ]
        sibling1 = @createConcept "sibling1"
        sibling2 = @createConcept "sibling2"
        parent = @createConcept "parent", sub_concept_ids: ["sibling1", "sibling2", "hit"]
        @hits.update [ id: "hit" ]
        @hits.nodes().should.have.property("sibling1").with.property "concept", sibling1
        @hits.nodes().should.have.property("sibling2").with.property "concept", sibling2

      it "creates nodes for children", ->
        hit = @createConcept "hit", sub_concept_ids: [ "child1", "child2" ]
        child1 = @createConcept "child1"
        child2 = @createConcept "child2"
        @hits.update [ id: "hit" ]
        @hits.nodes().should.have.property("child1").with.property "concept", child1
        @hits.nodes().should.have.property("child2").with.property "concept", child2

    context "hit references", ->

      beforeEach ->
        @concept = @createConcept "123abc"
      
      it "references hit for hit", ->
        hit = new Coreon.Models.Hit id: "123abc"
        @hits.update [ hit ], silent: true
        @hits.nodes().should.have.deep.property "123abc.hit", hit

      it "sets hit to null for parent", ->
        @createConcept "fff999"
        @concept.set "super_concept_ids", ["fff999"], silent: true
        @hits.update [ id: "123abc" ], silent: true
        @hits.nodes().should.have.deep.property "fff999.hit", null
        
      it "sets hit to null for child", ->
        @createConcept "fff999"
        @concept.set "sub_concept_ids", ["fff999"], silent: true
        @hits.update [ id: "123abc" ], silent: true
        @hits.nodes().should.have.deep.property "fff999.hit", null

      it "sets hit to null for sibling", ->
        @createConcept "fff999"
        @createConcept "sdf78f", sub_concept_ids: ["fff999", "123abc"]
        @concept.set "super_concept_ids", ["sdf78f"], silent: true
        @hits.update [ id: "123abc" ], silent: true
        @hits.nodes().should.have.deep.property "fff999.hit", null
        
    context "memoizing", ->
      
      it "is created only once", ->
        @hits.nodes().should.equal @hits.nodes()

      it "is recreated after update", ->
        @createConcept "123abc"
        deprecated = @hits.nodes()
        @hits.update [ id: "123abc" ], silent: true
        @hits.nodes().should.not.equal deprecated
      
  describe "edges()", ->

    beforeEach ->
      @nodes =
        "799":
          concept: @concept
      @hits.nodes = => @nodes 

    context "creating edges", ->
  
      it "returns empty hash when there are no hits", ->
        @hits.edges().should.be.an "array"
        @hits.edges().should.be.empty

      it "creates edge for parent with corresponding node", ->
        @nodes["fff999"] = concept: @createConcept "fff999"
        @concept.set "super_concept_ids", [ "fff999" ], silent: true
        @hits.edges().should.have.deep.property('[0]').that.eql
          source: @nodes["fff999"]
          target: @nodes["799"]

      it "skips edge for parent without corresponding node", ->
        @concept.set "super_concept_ids", [ "fff999" ], silent: true
        @hits.edges().should.be.empty
      
      it "creates edge for every parent that has a corresponding node", ->
        @nodes["fff999"] = concept: @createConcept "fff999"
        @nodes["ggg555"] = concept: @createConcept "ggg555"
        @concept.set "super_concept_ids", [ "fff999", "ggg555" ], silent: true
        @hits.edges().should.have.length 2

      it "creates edges for every node that has parents", ->
        @nodes["fff999"] = concept: @createConcept("fff999", super_concept_ids: [ "799" ])
        @nodes["ggg555"] = concept: @createConcept("ggg555", super_concept_ids: [ "799" ])
        @hits.edges().should.have.length 2

    context "memoizing", ->
      
      it "is created only once", ->
        @hits.edges().should.equal @hits.edges()

      it "is recreated after update", ->
        @createConcept "123abc"
        deprecated = @hits.edges()
        @hits.update [ id: "123abc" ], silent: true
        @hits.edges().should.not.equal deprecated

  describe "digraphs()", ->

    context "building digraphs", ->
      
      it "returns empty array when there are no hits", ->
        @hits.digraphs().should.be.an "array"
        @hits.digraphs().should.be.empty

      it "creates a digraph for every root node"
        

  # TODO: extract graph functionality?
      
