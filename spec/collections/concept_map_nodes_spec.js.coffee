#= require spec_helper
#= require collections/concept_map_nodes

describe "Coreon.Collections.ConceptMapNode", ->

  beforeEach ->
    @repository = new Backbone.Model
    Coreon.application = repository: => @repository
    sinon.stub Coreon.Models.Concept, "find"
    @collection = new Coreon.Collections.ConceptMapNodes

  afterEach ->
    Coreon.Models.Concept.find.restore()
    delete Coreon.application

  it "is a Backbone collection", ->
    @collection.should.be.an.instanceof Coreon.Collections.ConceptMapNodes

  it "creates ConceptMapNode models", ->
    @collection.reset [ id: "node" ], silent: yes
    @collection.should.have.lengthOf 1
    @collection.at(0).should.be.an.instanceof Coreon.Models.ConceptMapNode

  describe "#build()", ->
      
    it "removes old nodes", ->
      @collection.reset [ id: "node" ], silent: yes
      node = @collection.at(0)
      @collection.build()
      expect( @collection.get node ).to.not.exist

    it "creates root node", ->
      @collection.reset [], silent: yes
      @collection.build()
      root = @collection.at(0)
      expect( root ).to.exist
      expect( root.get "model" ).to.equal @repository

    it "creates nodes for passed in models", ->
      concept = new Backbone.Model id: "concept-123"
      @collection.build [ concept ]
      node = @collection.get "concept-123"
      expect( node ).to.exist
      expect( node.get "model" ).to.equal concept

    context "when completely loaded", ->

      beforeEach ->
        @collection.isLoaded = -> yes
      
      it "succeeds immediately", ->
        spy = sinon.spy()
        promise = @collection.build()
        promise.done spy
        expect( promise.state() ).to.equal "resolved"
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledOn @collection
        expect( spy ).to.have.been.calledWith @collection.models

    context "when loading parent nodes", ->
      
      beforeEach ->
        @collection.isLoaded = -> no
      
      it "defers callbacks", ->
        spy = sinon.spy()
        promise = @collection.build()
        promise.done spy
        expect( promise.state() ).to.equal "pending"
        expect( spy ).to.not.have.been.called

      it "succeeds when all nodes are loaded", ->
        spy = sinon.spy()
        promise = @collection.build()
        promise.done spy
        @collection.isLoaded = -> yes
        @collection.trigger "change:loaded"
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledOn @collection
        expect( spy ).to.have.been.calledWith @collection.models
        
      it "fails when build is called again", ->
        spy = sinon.spy()
        promise = @collection.build()
        nodes = (node for node in @collection.models)
        promise.fail spy
        @collection.build()
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledOn @collection
        expect( spy ).to.have.been.calledWith nodes

      it "fails if a request is aborted", ->
        spy = sinon.spy()
        promise = @collection.build()
        nodes = (node for node in @collection.models)
        promise.fail spy
        @collection.trigger "error"
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledOn @collection
        expect( spy ).to.have.been.calledWith nodes

  describe "#isLoaded()", ->

    it "is true when all nodes are loaded", ->
      @collection.reset [
        { loaded: yes }
        { loaded: yes }
        { loaded: yes }
      ], silent: yes
      expect( @collection.isLoaded() ).to.be.true
    
    it "is false when at least one node is not loaded", ->
      @collection.reset [
        { loaded: yes }
        { loaded: no }
        { loaded: yes }
      ], silent: yes
      expect( @collection.isLoaded() ).to.be.false

  describe "#addParentNodes()", ->

    beforeEach ->
      @node = new Backbone.Model
        id: "sdfg0987"
        parent_node_ids: []
        child_node_ids: []

    it "is triggered when a node was added", ->
      spy = sinon.spy()
      @collection.addParentNodes = spy
      @collection.initialize()
      @collection.trigger "add", @node
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledOn @collection
      expect( spy ).to.have.been.calledWith @node

    it "is triggered when parent node ids change", ->
      spy = sinon.spy()
      @collection.addParentNodes = spy
      @collection.initialize()
      @collection.trigger "change:parent_node_ids", @node
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledOn @collection
      expect( spy ).to.have.been.calledWith @node

    it "creates nodes from parent node ids", ->
      concept = new Backbone.Model id: "sdfg0987"
      Coreon.Models.Concept.find.withArgs("sdfg0987").returns concept
      @node.set "parent_node_ids", [ "sdfg0987" ], silent: yes
      @collection.addParentNodes @node
      parent = @collection.get "sdfg0987"
      expect( parent ).to.exist
      expect( parent.get "model" ).to.equal concept

  describe "#addChildNodes", ->
  
    beforeEach ->
      @node = new Backbone.Model
        id: "sdfg0987"
        parent_node_ids: []
        child_node_ids: []

    it "is triggered when a node was added", ->
      spy = sinon.spy()
      @collection.addChildNodes = spy
      @collection.initialize()
      @collection.trigger "add", @node
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledOn @collection
      expect( spy ).to.have.been.calledWith @node

    it "is triggered when child node ids change", ->
      spy = sinon.spy()
      @collection.addChildNodes = spy
      @collection.initialize()
      @collection.trigger "change:child_node_ids", @node
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledOn @collection
      expect( spy ).to.have.been.calledWith @node

    context "expanded", ->

      it "creates nodes from child node ids"

    context "not expanded", ->

      it "creates placeholder node"

      it "creates only one placeholder node"
