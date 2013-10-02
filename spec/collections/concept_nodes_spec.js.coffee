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

    context "connecting hits", ->
        
      beforeEach ->
        @concept = new Backbone.Model
        @hit = new Backbone.Model result: @concept
        @hits = new Backbone.Collection [ @hit ]
        @collection.initialize [], hits: @hits
      
      it "assigns hits from options", ->
        @collection.hits.should.equal @hits
    
      it "resets from hits", ->
        @concept.id = "concept"
        @collection.initialize [], hits: @hits
        @collection.should.have.length 1
        @collection.at(0).get("hit").should.equal @hit
        @collection.at(0).should.have.property "id", "concept"

      it "expands nodes from hits", ->
        @collection.at(0).get("expandedOut").should.be.true

      it "is updated when hits are reset", ->
        other = new Backbone.Model
        @hits.reset [ result: other ]
        @collection.should.have.length 1
        @collection.at(0).get("concept").should.equal other

  describe "root()", ->

     it "returns root node", ->
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
          expandedOut: yes
        ], silent: true
        node = @collection.get "123"
        @collection.tree().should.have.deep.property "root.children[0].id", "123"
        @collection.tree().should.have.deep.property "root.children[0].label", "node"
        @collection.tree().should.have.deep.property "root.children[0].hit", yes
        @collection.tree().should.have.deep.property "root.children[0].expandedOut", yes
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

     it "defaults expansion states to false", ->
        @collection.reset [ id: "123" ], silent: true
        node = @collection.get "123"
        @collection.tree().should.have.deep.property "root.children[0].expandedOut", no

     context "datum updates on model changes", ->

       it "updates label", ->
         @collection.reset [
           id: "123"
           label: "before123"
           subconcept_ids: []
         ], silent: true
         node = @collection.get "123"
         @collection.tree()
         node.set "label", "after123"
         @collection.tree().root.children[0].should.have.property "label", "after123"

       it "updates hit status", ->
         @collection.reset [
           hit: null
           subconcept_ids: []
         ], silent: true
         @collection.tree()
         @collection.first().set "hit", { score: "2.67" }
         @collection.tree().root.children[0].should.have.property "hit", yes

       it "updates leaf status", ->
         @collection.reset [ subconcept_ids: [ "child" ] ], silent: true
         @collection.tree()
         @collection.first().set "subconcept_ids", []
         @collection.tree().root.children[0].should.have.property "leaf", yes
    
  describe "remove()", ->

    context "removing subnodes", ->
    
      it "removes subnodes", ->
        @collection.reset [
          { id: "node" }
          { id: "subnode_1", superconcept_ids: [ "node" ] }
          { id: "subnode_2", superconcept_ids: [ "node" ] }
          { id: "other" }
        ], silent: true
        @collection.remove "node"
        @collection.should.have.length 1
        @collection.at(0).should.have.property "id", "other"
        
      it "removes subnodes recursively", ->
        @collection.reset [
          { id: "node" }
          { id: "subnode", superconcept_ids: [ "node" ] }
          { id: "subnode_of_subnode", superconcept_ids: [ "subnode" ] }
        ], silent: true
        @collection.remove "node"
        @collection.should.have.length 0

      it "keeps nodes that belong to an expanded superconcept", ->
        @collection.reset [
          { id: "supernode", subconcept_ids: [ "subnode" ], expandedOut: true }
          { id: "subnode" }
        ], silent: true
        @collection.remove "subnode"
        @collection.should.have.length 2
        should.exist @collection.get "subnode"

      it "removes nodes that belong to a collapsed superconcept", ->
        @collection.reset [
          { id: "supernode", subconcept_ids: [ "subnode" ], expandedOut: false }
          { id: "subnode" }
        ], silent: true
        @collection.remove "subnode"
        @collection.should.have.length 1
        should.not.exist @collection.get "subnode"

      it "keeps subnodes that belong to another superconcept", ->
        @collection.reset [
          { id: "super_1", subconcept_ids: [ "subnode" ] }
          { id: "super_2", subconcept_ids: [ "subnode" ] }
          { id: "subnode" }
        ], silent: true
        @collection.remove "super_1"
        @collection.should.have.length 2
        should.exist @collection.get "subnode"

      it "removes subnodes with more than one parent connected to superconcept", ->
        @collection.reset [
          { id: "super", subconcept_ids: [ "subnode_1", "subnode_2" ] }
          { id: "subnode_1", subconcept_ids: [ "multiparent" ] }
          { id: "subnode_2", subconcept_ids: [ "multiparent" ] }
          { id: "multiparent" }
        ], silent: true
        @collection.remove "super"
        @collection.should.have.length 0

  describe "focus()", ->

    it "removes supernodes", ->
      @collection.reset [
        { id: "root", subconcept_ids: [ "supernode" ] }
        { id: "supernode", subconcept_ids: [ "subnode" ] }
        { id: "subnode", subconcept_ids: [ "leaf"] }
        { id: "leaf" }
      ], silent: true
      @collection.focus "subnode"
      @collection.should.have.length 2
      should.exist @collection.get "subnode"
      should.exist @collection.get "leaf"

    it "keeps supernodes that are not connected", ->
      @collection.reset [
        { id: "root_1" }
        { id: "root_2", subconcept_ids: [ "subnode" ] }
        { id: "subnode" }
      ], silent: true
      @collection.focus "subnode"
      @collection.should.have.length 2
      should.exist @collection.get "root_1"

  describe "add()", ->

    context "spreading out", ->

      context "expanding edges out", ->

        it "adds targets when expanded", ->
          @collection.add [
            id: "node"
            subconcept_ids: [ "subnode_1", "subnode_2" ]
            expandedOut: true
          ]
          @collection.should.have.length 3
          should.exist @collection.get "subnode_1"
          should.exist @collection.get "subnode_2"

        it "does not add nodes when not expanded", ->
          @collection.add [
            id: "node"
            subconcept_ids: [ "subnode_1", "subnode_2" ]
            expandedOut: false
          ]
          @collection.should.have.length 1
        
        it "does not expand added nodes", ->
          @collection.add [
            id: "node"
            subconcept_ids: [ "subnode" ]
            expandedOut: true
          ]
          @collection.get("subnode").get("expandedOut").should.be.false

      context "updating expansion states", ->

        it "expands supernodes", ->
          @collection.reset [
            id: "supernode",
            expandedOut: false
            subconcept_ids: [ "node" ]
          ], silent: true
          @collection.add id: "node"
          @collection.get("supernode").get("expandedOut").should.be.true

  describe "reset()", ->

    context "spreading out", ->

      context "expanding edges out", ->

        it "resets targets when expanded", ->
          @collection.reset [
            id: "node"
            subconcept_ids: [ "subnode_1", "subnode_2" ]
            expandedOut: true
          ]
          @collection.should.have.length 3
          should.exist @collection.get "subnode_1"
          should.exist @collection.get "subnode_2"

        it "does not reset nodes when not expanded", ->
          @collection.reset [
            id: "node"
            subconcept_ids: [ "subnode_1", "subnode_2" ]
            expandedOut: false
          ]
          @collection.should.have.length 1
        
        it "does not expand reseted nodes", ->
          @collection.reset [
            id: "node"
            subconcept_ids: [ "subnode" ]
            expandedOut: true
          ]
          @collection.get("subnode").get("expandedOut").should.equal false

      context "updating expansion states", ->

        it "expands supernodes", ->
          @collection.reset [
            { id: "node" }
            { id: "supernode", expandedOut: false, subconcept_ids: [ "node" ] }
          ]
          @collection.get("supernode").get("expandedOut").should.be.true

  describe "on change:subconcept_ids", ->

    context "spreading out", ->
      
      beforeEach ->
        @collection.reset [
          id: "node"
          subconcept_ids: [ "subnode_1" ]
          expandedOut: true
        ]
        @node = @collection.get "node"
      
      it "removes deprecated subnodes", ->
        @node.set "subconcept_ids", []
        @collection.should.have.length 1
        should.not.exist @collection.get "subnode_1"

      it "creates subnode for added ids", ->
        @node.set "subconcept_ids", [ "subnode_1", "subnode_2" ]
        @collection.should.have.length 3
        should.exist @collection.get "subnode_2"

      it "handles undefined targetIds gracefully", ->
        @node.set "subconcept_ids", null
        @node.set "subconcept_ids", [ "subnode_1", "subnode_2" ]
        @collection.should.have.length 3
        should.exist @collection.get "subnode_2"

      it "does nothing when collapsed", ->
        @node.set "expandedOut", false, silent: true
        @node.set "subconcept_ids", [ "subnode_2" ]
        @collection.should.have.length 2
        should.not.exist @collection.get "subnode_2"

    context "updating expansion states", ->

      it "expands out", ->
        @collection.reset [
          { id: "node" }
          { id: "supernode", expandedOut: false, subconcept_ids: [ "node", "other" ] }
        ], silent: true
        node = @collection.get("supernode")
        node.set "subconcept_ids", [ "node" ]
        node.get("expandedOut").should.be.true
        
  describe "on change:expandedOut", ->

    beforeEach ->
      @collection.reset [
        id: "node"
        subconcept_ids: [ "subnode" ]
        expandedOut: false
      ], silent: true
      @node = @collection.get "node"

    it "expands children when set to true", ->
      @node.set "expandedOut", true
      @collection.should.have.length 2
      should.exist @collection.get "subnode"

    it "removes children when set to false", ->
      @node.set "expandedOut", true
      @node.set "expandedOut", false
      @collection.should.have.length 1
      should.not.exist @collection.get "subnode"
