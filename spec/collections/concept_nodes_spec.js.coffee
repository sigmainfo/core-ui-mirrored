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

      it "uses cid for hit on new concept", ->
        @concept.cid = "c234"
        @collection.initialize [], hits: @hits
        @collection.should.have.length 1
        @collection.at(0).should.have.property "id", "c234"
        

      it "expands nodes from hits", ->
        @collection.at(0).get("expandedIn").should.be.true
        @collection.at(0).get("expandedOut").should.be.true

      it "is updated when hits are reset", ->
        other = new Backbone.Model
        @hits.reset [ result: other ]
        @collection.should.have.length 1
        @collection.at(0).get("concept").should.equal other

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

    context "updating expansion state", ->
      
      it "collapses subnodes", ->
        @collection.reset [
          { id: "node" }
          { id: "other", expandedIn: true }
          { id: "subnode_1", superconcept_ids: [ "node", "other" ], expandedIn: true }
          { id: "subnode_2", superconcept_ids: [ "node", "other" ], expandedIn: true }
        ], silent: true
        @collection.remove "node"
        @collection.get("subnode_1").get("expandedIn").should.be.false 
        @collection.get("subnode_2").get("expandedIn").should.be.false 
        @collection.get("other").get("expandedIn").should.be.true

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

      context "expanding edges in", ->
        
        it "adds sources when expanded", ->
          @collection.add [
            id: "node"
            superconcept_ids: [ "supernode_1", "supernode_2" ]
            expandedIn: true
          ]
          @collection.should.have.length 3
          should.exist @collection.get "supernode_1"
          should.exist @collection.get "supernode_2"

        it "does not add nodes when not expanded", ->
          @collection.add [
            id: "node"
            superconcept_ids: [ "supernode_1", "supernode_2" ]
            expandedIn: false
          ]
          @collection.should.have.length 1
        
        it "expands out added nodes", ->
          @collection.add [
            id: "node"
            superconcept_ids: [ "supernode" ]
            expandedIn: true
          ]
          @collection.get("supernode").get("expandedOut").should.equal true

      context "updating expansion states", ->

        it "expands supernodes", ->
          @collection.reset [
            id: "supernode",
            expandedOut: false
            subconcept_ids: [ "node" ]
          ], silent: true
          @collection.add id: "node"
          @collection.get("supernode").get("expandedOut").should.be.true

        it "expands subnodes", ->
          @collection.reset [
            id: "subnode",
            expandedIn: false
            superconcept_ids: [ "node" ]
          ], silent: true
          @collection.add id: "node"
          @collection.get("subnode").get("expandedIn").should.be.true
          
        
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

      context "expanding edges in", ->
        
        it "resets sources when expanded", ->
          @collection.reset [
            id: "node"
            superconcept_ids: [ "supernode_1", "supernode_2" ]
            expandedIn: true
          ]
          @collection.should.have.length 3
          should.exist @collection.get "supernode_1"
          should.exist @collection.get "supernode_2"

        it "does not reset nodes when not expanded", ->
          @collection.reset [
            id: "node"
            superconcept_ids: [ "supernode_1", "supernode_2" ]
            expandedIn: false
          ]
          @collection.should.have.length 1
        
        it "expands out reseted nodes", ->
          @collection.reset [
            id: "node"
            superconcept_ids: [ "supernode" ]
            expandedIn: true
          ]
          @collection.get("supernode").get("expandedOut").should.equal true

      context "updating expansion states", ->

        it "expands supernodes", ->
          @collection.reset [
            { id: "node" }
            { id: "supernode", expandedOut: false, subconcept_ids: [ "node" ] }
          ]
          @collection.get("supernode").get("expandedOut").should.be.true

        it "expands subnodes", ->
          @collection.reset [
            { id: "node" }
            { id: "subnode", expandedIn: false, superconcept_ids: [ "node" ] }
          ]
          @collection.add id: "node"
          @collection.get("subnode").get("expandedIn").should.be.true

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
        
  describe "on change:superconcept_ids", ->

    context "spreading out", ->
      
      beforeEach ->
        @collection.reset [
          id: "node"
          superconcept_ids: [ "supernode_1" ]
          expandedIn: true
        ]
        @node = @collection.get "node"
      
      it "removes deprecated supernodes", ->
        @node.set "superconcept_ids", []
        @collection.should.have.length 1
        should.not.exist @collection.get "supernode_1"

      it "creates supernode for added ids", ->
        @node.set "superconcept_ids", [ "supernode_1", "supernode_2" ]
        @collection.should.have.length 3
        should.exist @collection.get "supernode_2"
        @collection.get("supernode_2").get("expandedOut").should.be.true

      it "expands existing supernodes", ->
        @collection.add { id: "existing", expandedOut: false }, silent: true
        @node.set "superconcept_ids", [ "existing" ]
        @collection.get("existing").get("expandedOut").should.be.true

      it "handles undefined souceIds gracefully", ->
        @node.set "superconcept_ids", null
        @node.set "superconcept_ids", [ "supernode_1", "supernode_2" ]
        @collection.should.have.length 3
        should.exist @collection.get "supernode_2"

      it "does nothing when collapsed", ->
        @node.set "expandedIn", false, silent: true
        @node.set "superconcept_ids", [ "subnode_2" ]
        @collection.should.have.length 2
        should.not.exist @collection.get "subnode_2"

    context "updating expansion states", ->

      it "expands in", ->
        @collection.reset [
          { id: "node" }
          { id: "subnode", expandedOut: false, superconcept_ids: [ "node", "other" ] }
        ], silent: true
        node = @collection.get("subnode")
        node.set "superconcept_ids", [ "node" ]
        node.get("expandedIn").should.be.true


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

  describe "on change:expandedIn", ->

    it "expands parents when set to true", ->
      @collection.reset [
        id: "node"
        superconcept_ids: [ "supernode" ]
        expandedIn: false
      ], silent: true
      @collection.get("node").set "expandedIn", true
      @collection.should.have.length 2
      should.exist @collection.get "supernode"

    it "focuses node when set to false", ->
      @collection.reset [
        { id: "node", superconcept_ids: [ "supernode" ], expandedIn: true }
        { id: "supernode", superconcept_ids: ["root"] }
        { id: "root" }
      ], silent: true
      @collection.get("node").set "expandedIn", false
      @collection.should.have.length 1
      should.not.exist @collection.get "supernode"
      should.not.exist @collection.get "root"

