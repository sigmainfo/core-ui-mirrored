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

      it "returns empty array when there are no hits", ->
        @hits.nodes().should.be.an "array"
        @hits.nodes().should.be.empty
 

      it "creates nodes for hits", ->
        hit1 = @createConcept "hit1"
        hit2 = @createConcept "hit2"
        @hits.update [
          { id: "hit1" }
          { id: "hit2" }
        ]
        node1 = node for node in @hits.nodes() when node.id is "hit1"
        node1.should.have.property "concept", hit1
        node2 = node for node in @hits.nodes() when node.id is "hit2"
        node2.should.have.property "concept", hit2

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
        node1 = node for node in @hits.nodes() when node.id is "parent1"
        node1.should.have.property "concept", parent1
        node2 = node for node in @hits.nodes() when node.id is "parent2"
        node2.should.have.property "concept", parent2
        node3 = node for node in @hits.nodes() when node.id is "parent3"
        node3.should.have.property "concept", parent3

      it "creates nodes for siblings", ->
        hit = @createConcept "hit", super_concept_ids: [ "parent" ]
        sibling1 = @createConcept "sibling1"
        sibling2 = @createConcept "sibling2"
        parent = @createConcept "parent", sub_concept_ids: ["sibling1", "sibling2", "hit"]
        @hits.update [ id: "hit" ]
        node1 = node for node in @hits.nodes() when node.id is "sibling1"
        node1.should.have.property "concept", sibling1
        node2 = node for node in @hits.nodes() when node.id is "sibling2"
        node2.should.have.property "concept", sibling2

      it "creates nodes for children", ->
        hit = @createConcept "hit", sub_concept_ids: [ "child1", "child2" ]
        child1 = @createConcept "child1"
        child2 = @createConcept "child2"
        @hits.update [ id: "hit" ]
        node1 = node for node in @hits.nodes() when node.id is "child1"
        node1.should.have.property "concept", child1
        node2 = node for node in @hits.nodes() when node.id is "child2"
        node2.should.have.property "concept", child2

      it "does not create duplicates", ->
        parent = @createConcept "parent"
        hit1 = @createConcept "hit1", super_concept_ids: [ "parent" ]
        hit2 = @createConcept "hit2", super_concept_ids: [ "parent" ]
        @hits.update [
          { id: "hit1" }
          { id: "hit2" }
        ]
        nodes = []
        nodes.push node for node in @hits.nodes() when node.id is "parent"
        nodes.should.have.length 1


    context "hit references", ->

      it "references hit for hit", ->
        hit = new Coreon.Models.Hit id: "799"
        @hits.update [ hit ], silent: true
        hitNode = node for node in @hits.nodes() when node.id = "799" 
        hitNode.should.have.property "hit", hit

      it "sets hit to null for parent", ->
        @createConcept "fff999"
        @concept.set "super_concept_ids", ["fff999"], silent: true
        @hits.update [ id: "799" ], silent: true
        parentNode = node for node in @hits.nodes() when node.id = "fff999" 
        parentNode.should.have.property "hit", null
        
      it "sets hit to null for child", ->
        @createConcept "fff999"
        @concept.set "sub_concept_ids", ["fff999"], silent: true
        @hits.update [ id: "799" ], silent: true
        childNode = node for node in @hits.nodes() when node.id = "fff999" 
        childNode.should.have.property "hit", null

      it "sets hit to null for sibling", ->
        @createConcept "fff999"
        @createConcept "sdf78f", sub_concept_ids: ["fff999", "799"]
        @concept.set "super_concept_ids", ["sdf78f"], silent: true
        @hits.update [ id: "799" ], silent: true
        childNode = node for node in @hits.nodes() when node.id = "fff999" 
        childNode.should.have.property "hit", null

    context "relations", ->

      it "references target within children", ->
        @createConcept "fff999"
        @concept.set "super_concept_ids", ["fff999"], silent: true
        @hits.update [ id: "799" ], silent: true
        @hits.edges()[0].source.should.have.deep.property "children[0].id", "799"

      it "references source within parents", ->
        @createConcept "fff999"
        @concept.set "super_concept_ids", ["fff999"], silent: true
        @hits.update [ id: "799" ], silent: true
        @hits.edges()[0].target.should.have.deep.property "parents[0].id", "fff999"

      it "references multiple parents", ->
        @createConcept "fff999"
        @createConcept "555ttt"
        @concept.set "super_concept_ids", ["fff999", "555ttt"], silent: true
        @hits.update [ id: "799" ], silent: true
        @hits.edges()[0].target.parents.should.have.length 2

      it "references multiple children", ->
        @createConcept "fff999", super_concept_ids: [ "799" ]
        @createConcept "555ttt", super_concept_ids: [ "799" ]
        @concept.set "sub_concept_ids", ["fff999", "555ttt"], silent: true
        @hits.update [ id: "799" ], silent: true
        @hits.edges()[0].source.children.should.have.length 2

      it "defaults parents and children to null", ->
        @hits.update [ id: "799" ], silent: true
        @hits.nodes()[0].should.have.property "children", null
        @hits.nodes()[0].should.have.property "parents", null

    context "memoizing", ->
      
      it "is created only once", ->
        @hits.nodes().should.equal @hits.nodes()

      it "is recreated after update", ->
        @createConcept "123abc"
        deprecated = @hits.nodes()
        @hits.update [ id: "123abc" ], silent: true
        @hits.nodes().should.not.equal deprecated
      
  describe "edges()", ->

    context "creating edges", ->
  
      it "returns empty hash when there are no hits", ->
        @hits.edges().should.be.an "array"
        @hits.edges().should.be.empty

      it "creates edge for parent", ->
        @createConcept "123abc"
        @concept.set "super_concept_ids", [ "123abc" ], silent: true
        @hits.update [ id: "799" ], silent: true
        @hits.edges().should.have.deep.property "[0].source.id", "123abc"
        @hits.edges().should.have.deep.property "[0].target.id", "799"

      it "creates edges for multiple parents", ->
        @createConcept "123abc"
        @createConcept "fff999"
        @concept.set "super_concept_ids", [ "123abc", "fff999" ], silent: true
        @hits.update [ id: "799" ], silent: true
        @hits.edges().should.have.length 2        

      it "does not create edge for concepts without corresponding node", ->
        @createConcept "123abc", super_concept_ids: [ "333uuu" ]
        @concept.set "super_concept_ids", [ "123abc" ], silent: true
        @hits.update [ id: "799" ], silent: true
        @hits.edges().should.have.length 1        

    context "memoizing", ->
      
      it "is created only once", ->
        @hits.edges().should.equal @hits.edges()

      it "is recreated after update", ->
        @createConcept "123abc"
        deprecated = @hits.edges()
        @hits.update [ id: "123abc" ], silent: true
        @hits.edges().should.not.equal deprecated

  describe "roots()", ->

    it "returns all nodes that do not have a parent", ->
      hit = @createConcept "hit", super_concept_ids: [ "parent" ]
      sibling1 = @createConcept "sibling1", super_concept_ids: [ "parent" ]
      sibling2 = @createConcept "sibling2", super_concept_ids: [ "parent" ]
      parent = @createConcept "parent", sub_concept_ids: ["sibling1", "sibling2", "hit"]
      @hits.update [ id: "hit" ]
      @hits.roots().should.have.length 1
      @hits.roots()[0].should.have.property "id", "parent"
         
