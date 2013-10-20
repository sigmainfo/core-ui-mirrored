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

    it "defaults loading tree state to false", ->
      @collection.loadingTree.should.be.false

  describe "resetFromHits()", ->

    beforeEach ->
      @concept1 = new Backbone.Model
      @concept2 = new Backbone.Model
      @hit1 = new Backbone.Model result: @concept1
      @hit2 = new Backbone.Model result: @concept2
      @hits = new Backbone.Collection [ @hit1, @hit2 ]

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
      @collection.resetFromHits @hits
      @collection.reset.should.have.been.calledOnce
      @collection.reset.should.have.been.calledWith [
        { concept: @concept1, hit: @hit1} 
        { concept: @concept2, hit: @hit2 } 
      ]

    it "adds supernodes for each model", ->
      @collection.addSupernodes = sinon.spy()
      @collection.resetFromHits @hits
      @collection.addSupernodes.should.have.been.calledTwice
      @collection.addSupernodes.should.have.been.calledWith @collection.at(0)
      @collection.addSupernodes.should.have.been.calledWith @collection.at(1)

    it "triggers reset event after supernodes have been added", ->
      ids = null
      spy = sinon.spy (collection, models) -> ids = (model.id for model in collection.models)
      prev = new Backbone.Model
      @collection.models = [ prev ]
      @collection.addSupernodes = -> @add id: "parent"
      @collection.isCompletelyLoaded = -> no
      @collection.on "reset", spy
      @collection.resetFromHits @hits
      spy.should.have.been.calledOnce
      spy.should.have.been.calledWith @collection,
        previousModels: [ prev ]
        loadingTree: yes
      ids.should.include "parent"

    it "updates loading tree state", ->
      @collection.isCompletelyLoaded = -> no
      @collection.resetFromHits @hits
      @collection.loadingTree.should.be.true

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
      @collection.reset [ concept: @concept ], silent: yes
      @collection.addSupernodes @collection.get("concept")
      @collection.should.have.lengthOf 3
      node1 = @collection.get "parent_1"
      should.exist node1
      node1.get("concept").should.equal parent1
      node2 = @collection.get "parent_2"
      should.exist node2
      node2.get("concept").should.equal parent2

    context "parent of hit", ->

    it "marks newly added nodes", ->
      parent = new Backbone.Model id: "parent"
      Coreon.Models.Concept.find.withArgs("parent").returns parent
      @concept.set {
        superconcept_ids: ["parent"]
        hit: new Backbone.Model
      }, silent: yes
      @collection.reset [ concept: @concept ], silent: yes
      @collection.addSupernodes @collection.get("concept")
      node = @collection.get "parent"
      node.get("parent_of_hit").should.be.true

    it "marks existing nodes", ->
      parent = new Backbone.Model id: "parent"
      Coreon.Models.Concept.find.withArgs("parent").returns parent
      @concept.set {
        superconcept_ids: ["parent"]
        hit: new Backbone.Model
      }, silent: yes
      @collection.reset [ {concept: @concept}, {concept: parent} ], silent: yes
      @collection.addSupernodes @collection.get("concept")
      node = @collection.get "parent"
      node.get("parent_of_hit").should.be.true

    it "marks parent of parent nodes", ->
      parent = new Backbone.Model id: "parent"
      Coreon.Models.Concept.find.withArgs("parent").returns parent
      @concept.set "superconcept_ids", ["parent"], silent: yes
      @collection.reset [ {concept: @concept, parent_of_hit: yes}, {concept: parent} ], silent: yes
      @collection.addSupernodes @collection.get("concept")
      node = @collection.get "parent"
      node.get("parent_of_hit").should.be.true

  describe "tree()", ->

    it "creates repository root node", ->
      Coreon.application.repository = ->
        id: "repo-123"
        get: (attr) -> "repo 123" if attr is "name"
      @collection.tree().should.have.deep.property "root.id", "repo-123"
      @collection.tree().should.have.deep.property "root.label", "repo 123"
      @collection.tree().should.have.deep.property "root.type", "repository"
      @collection.tree().should.have.deep.property("root.children").with.lengthOf 0

    it "defaults type to concept", ->
      @collection.reset [ id: "123" ], silent: true
      @collection.tree().root.children[0].should.have.property "type", "concept"

    it "accumulates data from models", ->
      @collection.reset [
        id: "123"
        label: "node"
        hit: yes
        expanded: yes
        parent_of_hit: yes
      ], silent: true
      node = @collection.get "123"
      @collection.tree().should.have.deep.property "root.children[0].id", "123"
      @collection.tree().should.have.deep.property "root.children[0].label", "node"
      @collection.tree().should.have.deep.property "root.children[0].hit", yes
      @collection.tree().should.have.deep.property "root.children[0].parent_of_hit", yes
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

    it "creates edges to repository root", ->
      @collection.reset [
        { id: "top_1" }
        { id: "top_2", subconcept_ids: [ "child_of_top_2" ] }
        { id: "child_of_top_2", superconcept_ids: [ "top_2" ] }
      ]
      root = @collection.tree().root
      edges = @collection.tree().edges
      edges.should.have.lengthOf 3
      rootEdges = (edge for edge in edges when edge.source is root)
      rootEdges[0].should.have.property "target", root.children[0]
      rootEdges[1].should.have.property "target", root.children[1]

    context "loading hits", ->
      
      beforeEach ->
        @concept1 = new Backbone.Model
        @concept2 = new Backbone.Model
        @hit1 = new Backbone.Model result: @concept1
        @hit2 = new Backbone.Model result: @concept2
        @hits = new Backbone.Collection [ @hit1, @hit2 ]
        @collection.isCompletelyLoaded = -> false
        @collection.resetFromHits @hits
  
      it "inserts placeholder for concept nodes", ->
        Coreon.application = repository: ->
          id: "my-repo-123"
          get: -> "MY REPO 123"
        @collection.tree().root.children.should.have.lengthOf 1
        placeholder = @collection.tree().root.children[0]
        placeholder.should.have.property "type", "placeholder"
        placeholder.should.have.property("children").that.is.empty
        placeholder.should.have.property "id", "+my-repo-123"

      it "removes placeholder when completely loaded", ->
        @collection.tree()
        @collection.isCompletelyLoaded = -> yes
        @collection.trigger "change:loaded"
        children = @collection.tree().root.children
        children.should.have.lengthOf 2
        types = child.type for child in children
        types.should.not.include "placeholder"
        
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

    it "updates hit state", ->
      @collection.reset [ hit: null ], silent: yes
      @collection.tree()
      node = @collection.at(0)
      node.set "hit", new Backbone.Model
      @collection.updateDatum node
      @collection.tree().should.have.deep.property "root.children[0].hit", yes

  describe "isCompletelyLoaded()", ->

    it "returns true when collection is empty", ->
      @collection.reset [], silent: yes
      @collection.isCompletelyLoaded().should.be.true
    
    it "returns false when at least one node is not loaded", ->
      @collection.reset [
        { loaded: yes }
        { loaded: no  }
      ], silent: yes
      @collection.isCompletelyLoaded().should.be.false

  describe "loaded", ->

    beforeEach ->
      @collection.reset [
        { loaded: no }
        { loaded: no }
      ], silent: yes
  
    it "triggers event when all nodes are loaded", ->
      spy = sinon.spy()
      @collection.on "loaded", spy
      @collection.at(0).set "loaded", yes
      @collection.at(1).set "loaded", yes
      spy.should.have.been.calledOnce

    it "does not trigger event when only some nodes are loaded", ->
      spy = sinon.spy()
      @collection.on "loaded", spy
      @collection.at(0).set "loaded", yes
      spy.should.not.have.been.called
