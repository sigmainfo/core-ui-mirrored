#= require spec_helper
#= require collections/concept_nodes

describe "Coreon.Collections.ConceptNodes", ->

  beforeEach ->
    Coreon.application = repository: ->
      id: "my-repo"
      get: -> "MY REPO"
    sinon.stub Coreon.Models.Concept, "find"
    @collection = new Coreon.Collections.ConceptNodes

  afterEach ->
    @collection.stopListening()
    Coreon.Models.Concept.find.restore()
    delete Coreon.application

  it "is a Treegraph collection", ->
    @collection.should.be.an.instanceof Coreon.Collections.Treegraph
    @collection.options.sourceIds.should.equal "superconcept_ids"
    @collection.options.targetIds.should.equal "subconcept_ids"

  it "creates ConceptNode models", ->
    @collection.add id: "node"
    @collection.get("node").should.be.an.instanceof Coreon.Models.ConceptNode

  describe "initialize()", ->

    it "calls super", ->
      sinon.stub Coreon.Collections.Treegraph::, "initialize"
      try
        @collection.initialize [ id: "node" ]
        Coreon.Collections.Treegraph::initialize.should.have.been.calledOnce
        Coreon.Collections.Treegraph::initialize.should.have.been.calledWith [ id: "node" ]
    
      finally
        Coreon.Collections.Treegraph::initialize.restore()

  describe "resetFromHits()", ->

    beforeEach ->
      @hits = new Backbone.Collection

    it "is triggered on init", ->
      @collection.resetFromHits = sinon.spy()
      @collection.initialize [], hits: @hits
      @collection.resetFromHits.should.have.been.calledOnce
      @collection.resetFromHits.should.have.been.calledWith @hits

    it 'is triggered when hits are reset', ->
      @collection.resetFromHits = sinon.spy()
      @collection.initialize [], hits: @hits
      @collection.resetFromHits.reset()
      @hits.trigger "reset"
      @collection.resetFromHits.should.have.been.calledOnce

    it "creates nodes from hits", ->
      @collection.reset = sinon.spy()
      concept1 = new Backbone.Model
      concept2 = new Backbone.Model
      hit1 = new Backbone.Model result: concept1
      hit2 = new Backbone.Model result: concept2
      @hits.reset [ hit1, hit2 ], silent: yes
      @collection.resetFromHits @hits
      @collection.reset.should.have.been.calledOnce
      @collection.reset.should.have.been.calledWith [
        { concept: concept1 } 
        { concept: concept2 } 
      ]
      
  describe "addSupernodes()", ->

    beforeEach ->
      @concept = new Backbone.Model id: "concept"

    it "is triggered when a concept was added", ->
      @collection.addSupernodes = sinon.spy()
      @collection.initialize()
      @collection.addSupernodes.reset()
      @collection.add concept: @concept
      @collection.addSupernodes.should.have.been.calledOnce
      @collection.addSupernodes.should.have.been.calledOn @collection
      @collection.addSupernodes.should.have.been.calledWith @collection.at(0)

    it "is triggerd for every model on reset", ->
      @collection.addSupernodes = sinon.spy()
      @collection.initialize()
      @collection.addSupernodes.reset()
      @collection.reset [ concept: @concept ]
      @collection.addSupernodes.should.have.been.calledOnce
      @collection.addSupernodes.should.have.been.calledOn @collection
      @collection.addSupernodes.should.have.been.calledWith @collection.at(0)

    it "is triggered on changes of superconcept ids", ->
      @collection.addSupernodes = sinon.spy()
      @collection.initialize()
      @collection.add concept: @concept, silent: yes
      @collection.addSupernodes.reset()
      node = @collection.at(0)
      node.set "superconcept_ids", ["parent"]
      @collection.addSupernodes.should.have.been.calledOnce
      @collection.addSupernodes.should.have.been.calledOn @collection
      @collection.addSupernodes.should.have.been.calledWith @collection.at(0)

    it "adds supernodes to collection", ->
      parent1 = new Backbone.Model id: "parent_1"
      parent2 = new Backbone.Model id: "parent_2"
      Coreon.Models.Concept.find.withArgs("parent_1").returns parent1
      Coreon.Models.Concept.find.withArgs("parent_2").returns parent2
      @concept.set "superconcept_ids", ["parent_1", "parent_2"], silent: yes
      @collection.add concept: @concept
      @collection.should.have.lengthOf 3
      node1 = @collection.get "parent_1"
      should.exist node1
      node1.get("concept").should.equal parent1
      node2 = @collection.get "parent_2"
      should.exist node2
      node2.get("concept").should.equal parent2

  describe "tree()", ->

     it "creates repository root node", ->
        Coreon.application.repository = ->
          id: "repo-123"
          get: (attr) -> "repo 123" if attr is "name"
        @collection.tree().should.have.deep.property "root.id", "repo-123"
        @collection.tree().should.have.deep.property "root.label", "repo 123"
        @collection.tree().should.have.deep.property "root.root", yes
        @collection.tree().should.have.deep.property("root.children").with.lengthOf 0

     it "accumulates data from models", ->
        @collection.reset [
          id: "123"
          label: "node"
          hit: yes
          expanded: yes
        ], silent: true
        node = @collection.get "123"
        @collection.tree().should.have.deep.property "root.children[0].id", "123"
        @collection.tree().should.have.deep.property "root.children[0].label", "node"
        @collection.tree().should.have.deep.property "root.children[0].hit", yes
        @collection.tree().should.have.deep.property "root.children[0].expanded", yes
        @collection.tree().should.have.deep.property("root.children[0].children").with.length 0

     it "identifies leaf nodes", ->
        @collection.reset [ subconcept_ids: [] ]
        @collection.tree().should.have.deep.property "root.children[0].leaf", yes
        @collection.reset [ subconcept_ids: [ "child" ] ]
        @collection.tree().should.have.deep.property "root.children[0].leaf", no

     it "defaults hit attribute to false", ->
        @collection.reset [ id: "123" ], silent: true
        node = @collection.get "123"
        @collection.tree().root.children[0].hit.should.be.false
  
  describe "updateDatum()", ->
  
    it "is triggered on label changes", ->
      @collection.updateDatum = sinon.spy()
      @collection.initialize()
      @collection.reset [ label: "before" ], silent: yes
      node = @collection.at(0)
      node.set "label", "after"
      @collection.updateDatum.should.have.been.calledOnce
      @collection.updateDatum.should.have.been.calledOn @collection
      @collection.updateDatum.should.have.been.calledWith node

    it "is triggered on hit changes", ->
      @collection.updateDatum = sinon.spy()
      @collection.initialize()
      @collection.reset [ hit: null ], silent: yes
      node = @collection.at(0)
      node.set "hit", new Backbone.Model
      @collection.updateDatum.should.have.been.calledOnce
      @collection.updateDatum.should.have.been.calledOn @collection
      @collection.updateDatum.should.have.been.calledWith node

    it "updates label", ->
      @collection.reset [ label: "before" ], silent: yes
      @collection.tree()
      node = @collection.at(0)
      node.set "label", "after", silent: yes
      @collection.updateDatum node
      @collection.tree().should.have.deep.property "root.children[0].label", "after"

    it "updates label", ->
      @collection.reset [ hit: null ], silent: yes
      @collection.tree()
      node = @collection.at(0)
      node.set "hit", new Backbone.Model
      @collection.updateDatum node
      @collection.tree().should.have.deep.property "root.children[0].hit", yes
