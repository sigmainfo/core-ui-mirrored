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

    it "adds after removing", ->
      @createConcept "7878"
      @hits.update [ @hit ], silent: true
      @hits.update [ id: "7878" ], silent: true
      @hits.models.should.have.length 1


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

    context "hit:graph:update", ->
      
      it "is triggered by concept changes", ->
        @hits.update [ @hit ], silent: true
        @createConcept "123"
        @hits.graph()
        @hits.on "hit:graph:update", @spy
        @concept.set "super_concept_ids", ["123"]
        @spy.should.have.been.calledOnce

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

  describe "graph()", ->
    
    it "returns a Digraph instance", ->
      @hits.graph().should.be.an.instanceof Coreon.Data.Digraph

    it "memoizes graph", ->
      @hits.graph().should.equal @hits.graph()

    it "recreates graph after update", ->
      memoized = @hits.graph()
      @hits.update [ @hit ], silent: true
      @hits.graph().should.not.equal memoized

    it "recreates graph after concept changes", ->
      @hits.update [ @hit ], silent: true
      memoized = @hits.graph()
      @createConcept "123"
      @concept.set "super_concept_ids", ["123"]
      @hits.graph().should.not.equal memoized

    it "creates graph from models", ->
      @hits.update [ @hit ], silent: true
      @hits.graph().nodes.should.have.length 1
      @hits.graph().nodes[0].should.have.property "id", "799"
      @hits.graph().nodes[0].should.have.property "concept", @concept

    it "creates edges from concept graph", ->
      @createConcept "fff999", super_concept_ids: [ "799" ]
      @concept.set "sub_concept_ids", [ "fff999" ]
      @hits.update [ @hit ], silent: true
      @hits.graph().edges.should.have.length 1
      @hits.graph().edges[0].should.have.deep.property "source.id", "799"
      @hits.graph().edges[0].should.have.deep.property "target.id", "fff999"

    it "creates nodes for parent concepts", ->
      @createConcept "fff999", sub_concept_ids: [ "799" ]
      @concept.set "super_concept_ids", [ "fff999" ]
      @hits.update [ @hit ], silent: true
      @hits.graph().nodes.should.have.length 2
      @hits.graph().edges[0].should.have.deep.property "source.id", "fff999"
      @hits.graph().edges[0].should.have.deep.property "target.id", "799"

    it "gets score from hit", ->
      @hit.set "score", 1.587
      @createConcept "fff999", sub_concept_ids: [ "799" ]
      @concept.set "super_concept_ids", [ "fff999" ]
      @hits.update [ @hit ], silent: true
      @hits.graph().edges[0].should.have.deep.property "target.score", 1.587
      @hits.graph().edges[0].should.have.deep.property "source.score", null

  describe "tree()", ->
    
    it "returns tree representation of graph", ->
      graph = @hits.graph()
      graph.tree = sinon.stub().returns id: "root"
      @hits.tree().should.eql id: "root"

  describe "edges()", ->
    
    it "returns edges of graph", ->
      graph = @hits.graph()
      graph.edges = [ source: "a", target: "b" ]
      @hits.edges().should.eql [ source: "a", target: "b" ]
