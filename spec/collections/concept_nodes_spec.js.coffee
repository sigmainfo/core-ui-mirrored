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
    @collection.options.sourceIds.should.equal "super_concept_ids"
    @collection.options.targetIds.should.equal "sub_concept_ids"

  it "creates ConceptNode models", ->
    @collection.add _id: "node"
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
          { _id: "node" }
          { _id: "subnode_1", super_concept_ids: [ "node" ] }
          { _id: "subnode_2", super_concept_ids: [ "node" ] }
          { _id: "other" }
        ], silent: true
        @collection.remove "node"
        @collection.should.have.length 1
        @collection.at(0).should.have.property "id", "other"
        
      it "removes subnodes recursively", ->
        @collection.reset [
          { _id: "node" }
          { _id: "subnode", super_concept_ids: [ "node" ] }
          { _id: "subnode_of_subnode", super_concept_ids: [ "subnode" ] }
        ], silent: true
        @collection.remove "node"
        @collection.should.have.length 0

      it "keeps nodes that belong to an expanded superconcept", ->
        @collection.reset [
          { _id: "supernode", sub_concept_ids: [ "subnode" ], expandedOut: true }
          { _id: "subnode" }
        ], silent: true
        @collection.remove "subnode"
        @collection.should.have.length 2
        should.exist @collection.get "subnode"

      it "removes nodes that belong to a collapsed superconcept", ->
        @collection.reset [
          { _id: "supernode", sub_concept_ids: [ "subnode" ], expandedOut: false }
          { _id: "subnode" }
        ], silent: true
        @collection.remove "subnode"
        @collection.should.have.length 1
        should.not.exist @collection.get "subnode"

      it "keeps subnodes that belong to another superconcept", ->
        @collection.reset [
          { _id: "super_1", sub_concept_ids: [ "subnode" ] }
          { _id: "super_2", sub_concept_ids: [ "subnode" ] }
          { _id: "subnode" }
        ], silent: true
        @collection.remove "super_1"
        @collection.should.have.length 2
        should.exist @collection.get "subnode"

      it "removes subnodes with more than one parent connected to superconcept", ->
        @collection.reset [
          { _id: "super", sub_concept_ids: [ "subnode_1", "subnode_2" ] }
          { _id: "subnode_1", sub_concept_ids: [ "multiparent" ] }
          { _id: "subnode_2", sub_concept_ids: [ "multiparent" ] }
          { _id: "multiparent" }
        ], silent: true
        @collection.remove "super"
        @collection.should.have.length 0

    context "updating expansion state", ->
      
      it "collapses subnodes", ->
        @collection.reset [
          { _id: "node" }
          { _id: "other", expandedIn: true }
          { _id: "subnode_1", super_concept_ids: [ "node", "other" ], expandedIn: true }
          { _id: "subnode_2", super_concept_ids: [ "node", "other" ], expandedIn: true }
        ], silent: true
        @collection.remove "node"
        @collection.get("subnode_1").get("expandedIn").should.be.false 
        @collection.get("subnode_2").get("expandedIn").should.be.false 
        @collection.get("other").get("expandedIn").should.be.true

  describe "focus()", ->

    it "removes supernodes", ->
      @collection.reset [
        { _id: "root", sub_concept_ids: [ "supernode" ] }
        { _id: "supernode", sub_concept_ids: [ "subnode" ] }
        { _id: "subnode", sub_concept_ids: [ "leaf"] }
        { _id: "leaf" }
      ], silent: true
      @collection.focus "subnode"
      @collection.should.have.length 2
      should.exist @collection.get "subnode"
      should.exist @collection.get "leaf"

    it "keeps supernodes that are not connected", ->
      @collection.reset [
        { _id: "root_1" }
        { _id: "root_2", sub_concept_ids: [ "subnode" ] }
        { _id: "subnode" }
      ], silent: true
      @collection.focus "subnode"
      @collection.should.have.length 2
      should.exist @collection.get "root_1"

  describe "add()", ->

    context "spreading out", ->

      context "expanding edges out", ->

        it "adds targets when expanded", ->
          @collection.add [
            _id: "node"
            sub_concept_ids: [ "subnode_1", "subnode_2" ]
            expandedOut: true
          ]
          @collection.should.have.length 3
          should.exist @collection.get "subnode_1"
          should.exist @collection.get "subnode_2"

        it "does not add nodes when not expanded", ->
          @collection.add [
            _id: "node"
            sub_concept_ids: [ "subnode_1", "subnode_2" ]
            expandedOut: false
          ]
          @collection.should.have.length 1
        
        it "does not expand added nodes", ->
          @collection.add [
            _id: "node"
            sub_concept_ids: [ "subnode" ]
            expandedOut: true
          ]
          @collection.get("subnode").get("expandedOut").should.be.false

      context "expanding edges in", ->
        
        it "adds sources when expanded", ->
          @collection.add [
            _id: "node"
            super_concept_ids: [ "supernode_1", "supernode_2" ]
            expandedIn: true
          ]
          @collection.should.have.length 3
          should.exist @collection.get "supernode_1"
          should.exist @collection.get "supernode_2"

        it "does not add nodes when not expanded", ->
          @collection.add [
            _id: "node"
            super_concept_ids: [ "supernode_1", "supernode_2" ]
            expandedIn: false
          ]
          @collection.should.have.length 1
        
        it "expands out added nodes", ->
          @collection.add [
            _id: "node"
            super_concept_ids: [ "supernode" ]
            expandedIn: true
          ]
          @collection.get("supernode").get("expandedOut").should.equal true

      context "updating expansion states", ->

        it "expands supernodes", ->
          @collection.reset [
            _id: "supernode",
            expandedOut: false
            sub_concept_ids: [ "node" ]
          ], silent: true
          @collection.add _id: "node"
          @collection.get("supernode").get("expandedOut").should.be.true

        it "expands subnodes", ->
          @collection.reset [
            _id: "subnode",
            expandedIn: false
            super_concept_ids: [ "node" ]
          ], silent: true
          @collection.add _id: "node"
          @collection.get("subnode").get("expandedIn").should.be.true
          
        
  describe "reset()", ->

    context "spreading out", ->

      context "expanding edges out", ->

        it "resets targets when expanded", ->
          @collection.reset [
            _id: "node"
            sub_concept_ids: [ "subnode_1", "subnode_2" ]
            expandedOut: true
          ]
          @collection.should.have.length 3
          should.exist @collection.get "subnode_1"
          should.exist @collection.get "subnode_2"

        it "does not reset nodes when not expanded", ->
          @collection.reset [
            _id: "node"
            sub_concept_ids: [ "subnode_1", "subnode_2" ]
            expandedOut: false
          ]
          @collection.should.have.length 1
        
        it "does not expand reseted nodes", ->
          @collection.reset [
            _id: "node"
            sub_concept_ids: [ "subnode" ]
            expandedOut: true
          ]
          @collection.get("subnode").get("expandedOut").should.equal false

      context "expanding edges in", ->
        
        it "resets sources when expanded", ->
          @collection.reset [
            _id: "node"
            super_concept_ids: [ "supernode_1", "supernode_2" ]
            expandedIn: true
          ]
          @collection.should.have.length 3
          should.exist @collection.get "supernode_1"
          should.exist @collection.get "supernode_2"

        it "does not reset nodes when not expanded", ->
          @collection.reset [
            _id: "node"
            super_concept_ids: [ "supernode_1", "supernode_2" ]
            expandedIn: false
          ]
          @collection.should.have.length 1
        
        it "expands out reseted nodes", ->
          @collection.reset [
            _id: "node"
            super_concept_ids: [ "supernode" ]
            expandedIn: true
          ]
          @collection.get("supernode").get("expandedOut").should.equal true

      context "updating expansion states", ->

        it "expands supernodes", ->
          @collection.reset [
            { _id: "node" }
            { _id: "supernode", expandedOut: false, sub_concept_ids: [ "node" ] }
          ]
          @collection.get("supernode").get("expandedOut").should.be.true

        it "expands subnodes", ->
          @collection.reset [
            { _id: "node" }
            { _id: "subnode", expandedIn: false, super_concept_ids: [ "node" ] }
          ]
          @collection.add _id: "node"
          @collection.get("subnode").get("expandedIn").should.be.true

  describe "on change:sub_concept_ids", ->

    context "spreading out", ->
      
      beforeEach ->
        @collection.reset [
          _id: "node"
          sub_concept_ids: [ "subnode_1" ]
          expandedOut: true
        ]
        @node = @collection.get "node"
      
      it "removes deprecated subnodes", ->
        @node.set "sub_concept_ids", []
        @collection.should.have.length 1
        should.not.exist @collection.get "subnode_1"

      it "creates subnode for added ids", ->
        @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ]
        @collection.should.have.length 3
        should.exist @collection.get "subnode_2"

      it "handles undefined targetIds gracefully", ->
        @node.set "sub_concept_ids", null
        @node.set "sub_concept_ids", [ "subnode_1", "subnode_2" ]
        @collection.should.have.length 3
        should.exist @collection.get "subnode_2"

      it "does nothing when collapsed", ->
        @node.set "expandedOut", false, silent: true
        @node.set "sub_concept_ids", [ "subnode_2" ]
        @collection.should.have.length 2
        should.not.exist @collection.get "subnode_2"

    context "updating expansion states", ->

      it "expands out", ->
        @collection.reset [
          { _id: "node" }
          { _id: "supernode", expandedOut: false, sub_concept_ids: [ "node", "other" ] }
        ], silent: true
        node = @collection.get("supernode")
        node.set "sub_concept_ids", [ "node" ]
        node.get("expandedOut").should.be.true
        
  describe "on change:super_concept_ids", ->

    context "spreading out", ->
      
      beforeEach ->
        @collection.reset [
          _id: "node"
          super_concept_ids: [ "supernode_1" ]
          expandedIn: true
        ]
        @node = @collection.get "node"
      
      it "removes deprecated supernodes", ->
        @node.set "super_concept_ids", []
        @collection.should.have.length 1
        should.not.exist @collection.get "supernode_1"

      it "creates supernode for added ids", ->
        @node.set "super_concept_ids", [ "supernode_1", "supernode_2" ]
        @collection.should.have.length 3
        should.exist @collection.get "supernode_2"
        @collection.get("supernode_2").get("expandedOut").should.be.true

      it "expands existing supernodes", ->
        @collection.add { _id: "existing", expandedOut: false }, silent: true
        @node.set "super_concept_ids", [ "existing" ]
        @collection.get("existing").get("expandedOut").should.be.true

      it "handles undefined souceIds gracefully", ->
        @node.set "super_concept_ids", null
        @node.set "super_concept_ids", [ "supernode_1", "supernode_2" ]
        @collection.should.have.length 3
        should.exist @collection.get "supernode_2"

      it "does nothing when collapsed", ->
        @node.set "expandedIn", false, silent: true
        @node.set "super_concept_ids", [ "subnode_2" ]
        @collection.should.have.length 2
        should.not.exist @collection.get "subnode_2"

    context "updating expansion states", ->

      it "expands in", ->
        @collection.reset [
          { _id: "node" }
          { _id: "subnode", expandedOut: false, super_concept_ids: [ "node", "other" ] }
        ], silent: true
        node = @collection.get("subnode")
        node.set "super_concept_ids", [ "node" ]
        node.get("expandedIn").should.be.true


  describe "on change:expandedOut", ->

    beforeEach ->
      @collection.reset [
        _id: "node"
        sub_concept_ids: [ "subnode" ]
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
        _id: "node"
        super_concept_ids: [ "supernode" ]
        expandedIn: false
      ], silent: true
      @collection.get("node").set "expandedIn", true
      @collection.should.have.length 2
      should.exist @collection.get "supernode"

    it "focuses node when set to false", ->
      @collection.reset [
        { _id: "node", super_concept_ids: [ "supernode" ], expandedIn: true }
        { _id: "supernode", super_concept_ids: ["root"] }
        { _id: "root" }
      ], silent: true
      @collection.get("node").set "expandedIn", false
      @collection.should.have.length 1
      should.not.exist @collection.get "supernode"
      should.not.exist @collection.get "root"

