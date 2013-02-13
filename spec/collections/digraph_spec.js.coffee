#= require spec_helper
#= require collections/digraph

describe "Coreon.Collections.Digraph", ->

  beforeEach ->
    @graph = new Coreon.Collections.Digraph

  it "is a Backbone collection", ->
    @graph.should.be.an.instanceof Backbone.Collection

  describe "initialize()", ->
  
    it "prepares edgesIn", ->
      @graph.edgesIn.should.eql {}

    it "prepares edgesOut", ->
      @graph.edgesOut.should.eql {}

    it "takes option for target ids", ->
      @graph.initialize [], digraph: out: "__targets__"
      @graph.reset [
        { _id: "source", __targets__: [ "target" ] }
        { _id: "target" }
      ]
      @graph.edgesIn.should.have.deep.property "target.length", 1
      @graph.get("source").set "__targets__", []
      @graph.edgesIn.should.have.deep.property "target.length", 0

    it "takes option for source ids", ->
      @graph.initialize [], digraph: in: "__sources__"
      @graph.reset [
        { _id: "target", __sources__: [ "source" ] }
        { _id: "source" }
      ]
      @graph.edgesIn.should.have.deep.property "target.length", 1
      @graph.get("target").set "__sources__", []
      @graph.edgesIn.should.have.deep.property "target.length", 0

  describe "add()", ->
  
    it "can be chained", ->
      @graph.add().should.equal @graph

    it "calls super", ->
      sinon.spy Backbone.Collection::, "add"
      try
        @graph.add _id: "node"
        Backbone.Collection::add.should.have.been.calledOnce
        Backbone.Collection::add.should.have.been.calledWithExactly _id: "node"
      finally
        Backbone.Collection::add.restore()

    context "edgesIn", ->

      context "for nodes without target or source ids", ->

        it "creates empty array", ->
          @graph.add _id: "node"
          @graph.edgesIn.should.have.property "node"
          @graph.edgesIn["node"].should.be.an.instanceof Array
          @graph.edgesIn["node"].should.have.length 0
           
        it "handles multiple nodes", ->
          @graph.add [
            { _id: "node_1" }
            { _id: "node_2" }
          ]
          @graph.edgesIn.should.have.property "node_1"
          @graph.edgesIn.should.have.property "node_2"

      context "for nodes with target ids", ->

        it "creates edge for newly added node", ->
          @graph.reset [ _id: "target" ], silent: true
          @graph.add _id: "source", targetIds: [ "target" ]
          @graph.edgesIn.should.have.deep.property "target.length", 1
          @graph.edgesIn.should.have.deep.property "target[0]", @graph.get("source")

        it "drops edge to external node", ->
          @graph.add _id: "source", targetIds: [ "external" ]
          @graph.edgesIn.should.not.have.property "external"

        it "creates edge to existing node", ->
          @graph.reset [ _id: "source", targetIds: [ "target" ] ], silent: true
          @graph.add _id: "target"
          @graph.edgesIn.should.have.deep.property "target.length", 1
          @graph.edgesIn.should.have.deep.property "target[0]", @graph.get("source")

        it "does not create duplicates", ->
          @graph.reset [ _id: "source", targetIds: [ "target", "target" ] ], silent: true
          @graph.add _id: "target"
          @graph.edgesIn.should.have.deep.property "target.length", 1

      context "for nodes with source ids", ->
        
        it "creates edge for newly added node", ->
          @graph.reset [ _id: "source" ], silent: true
          @graph.add _id: "target", sourceIds: [ "source" ]
          @graph.edgesIn.should.have.deep.property "target.length", 1
          @graph.edgesIn.should.have.deep.property "target[0]", @graph.get("source")

        it "drops edge to external node", ->
          @graph.add _id: "target", sourceIds: [ "external" ]
          @graph.edgesIn.should.have.deep.property "target.length", 0

        it "creates edge to existing node", ->
          @graph.reset [ _id: "target", sourceIds: [ "source" ] ], silent: true
          @graph.add _id: "source"
          @graph.edgesIn.should.have.deep.property "target.length", 1
          @graph.edgesIn.should.have.deep.property "target[0]", @graph.get("source")

        it "does not create duplicates", ->
          @graph.reset [ _id: "target", sourceIds: [ "source", "source" ] ], silent: true
          @graph.add _id: "source"
          @graph.edgesIn.should.have.deep.property "target.length", 1

      context "for nodes with both source and target ids", ->
        
        it "does not create duplicates for target ids", ->
          @graph.reset [ _id: "target", sourceIds: [ "source" ] ], silent: true
          @graph.add _id: "source", targetIds: [ "target" ]
          @graph.edgesIn.should.have.deep.property "target.length", 1

        it "does not create duplicates for source ids", ->
          @graph.reset [ _id: "source", targetIds: [ "target" ] ], silent: true
          @graph.add _id: "target", sourceIds: [ "source" ]
          @graph.edgesIn.should.have.deep.property "target.length", 1

    context "edgesOut", ->
      
      context "for nodes without target or source ids", ->

        it "creates empty array", ->
          @graph.add _id: "node"
          @graph.edgesOut.should.have.property "node"
          @graph.edgesOut["node"].should.be.an.instanceof Array
          @graph.edgesOut["node"].should.have.length 0
           
        it "handles multiple nodes", ->
          @graph.add [
            { _id: "node_1" }
            { _id: "node_2" }
          ]
          @graph.edgesOut.should.have.property "node_1"
          @graph.edgesOut.should.have.property "node_2"

      context "for nodes with target ids", ->

        it "creates edge for newly added node", ->
          @graph.reset [ _id: "target" ], silent: true
          @graph.add _id: "source", targetIds: [ "target" ]
          @graph.edgesOut.should.have.deep.property "source.length", 1
          @graph.edgesOut.should.have.deep.property "source[0]", @graph.get("target")

        it "drops edge to external node", ->
          @graph.add _id: "source", targetIds: [ "external" ]
          @graph.edgesOut.should.have.deep.property "source.length", 0

        it "creates edge to existing node", ->
          @graph.reset [ _id: "source", targetIds: [ "target" ] ], silent: true
          @graph.add _id: "target"
          @graph.edgesOut.should.have.deep.property "source.length", 1
          @graph.edgesOut.should.have.deep.property "source[0]", @graph.get("target")

        it "does not create duplicates", ->
          @graph.reset [ _id: "source", targetIds: [ "target", "target" ] ], silent: true
          @graph.add _id: "target"
          @graph.edgesOut.should.have.deep.property "source.length", 1

      context "for nodes with source ids", ->
        
        it "creates edge for newly added node", ->
          @graph.reset [ _id: "source" ], silent: true
          @graph.add _id: "target", sourceIds: [ "source" ]
          @graph.edgesOut.should.have.deep.property "source.length", 1
          @graph.edgesOut.should.have.deep.property "source[0]", @graph.get("target")

        it "drops edge to external node", ->
          @graph.add _id: "target", sourceIds: [ "external" ]
          @graph.edgesOut.should.not.have.property "external"

        it "creates edge to existing node", ->
          @graph.reset [ _id: "target", sourceIds: [ "source" ] ], silent: true
          @graph.add _id: "source"
          @graph.edgesOut.should.have.deep.property "source.length", 1
          @graph.edgesOut.should.have.deep.property "source[0]", @graph.get("target")

        it "does not create duplicates", ->
          @graph.reset [ _id: "target", sourceIds: [ "source", "source" ] ], silent: true
          @graph.add _id: "source"
          @graph.edgesOut.should.have.deep.property "source.length", 1

      context "for nodes with both source and target ids", ->
        
        it "does not create duplicates for target ids", ->
          @graph.reset [ _id: "target", sourceIds: [ "source" ] ], silent: true
          @graph.add _id: "source", targetIds: [ "target" ]
          @graph.edgesOut.should.have.deep.property "source.length", 1

        it "does not create duplicates for source ids", ->
          @graph.reset [ _id: "source", targetIds: [ "target" ] ], silent: true
          @graph.add _id: "target", sourceIds: [ "source" ]
          @graph.edgesOut.should.have.deep.property "source.length", 1

  describe "remove()", ->
  
    it "can be chained", ->
      @graph.remove().should.equal @graph 

    it "calls super", ->
      @graph.reset [ _id: "node" ], silent: true
      sinon.spy Backbone.Collection::, "remove"
      try
        @graph.remove [ "node" ]
        Backbone.Collection::remove.should.have.been.calledOnce
        Backbone.Collection::remove.should.have.been.calledWithExactly [ "node" ]
      finally
        Backbone.Collection::remove.restore()

    context "edgesIn", ->
      
      it "removes edges for node", ->
        @graph.reset [ _id: "node" ], silent: true
        @graph.remove "node"
        @graph.edgesIn.should.not.have.property "node"

      it "removes node from edges", ->
        @graph.reset [
          { _id: "target", sourceIds: [ "source" ] }
          { _id: "source" }
        ], silent: true
        @graph.remove "source"
        @graph.edgesIn.should.have.deep.property "target.length", 0

      it "does create edge for deprecated source nodes", ->
        @graph.reset [ { _id: "source", targetIds: [ "target" ] } ], silent: true 
        @graph.remove "source"
        @graph.add _id: "target"
        @graph.edgesIn.should.have.deep.property "target.length", 0

    context "edgesOut", ->
      
      it "removes edges for node", ->
        @graph.reset [ _id: "node" ], silent: true
        @graph.remove "node"
        @graph.edgesOut.should.not.have.property "node"

      it "removes node from edges", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        @graph.remove "target"
        @graph.edgesOut.should.have.deep.property "source.length", 0

      it "does create edge for deprecated target nodes", ->
        @graph.reset [ { _id: "target", sourceIds: [ "source" ] } ], silent: true 
        @graph.remove "target"
        @graph.add _id: "source"
        @graph.edgesOut.should.have.deep.property "source.length", 0

  describe "reset()", ->
    
    it "empties edgesIn", ->
      @graph.reset [
        { _id: "node" }
      ], silent: true
      @graph.reset []
      @graph.edgesIn.should.be.empty
      
    it "empties edgesOut", ->
      @graph.reset [
        { _id: "node" }
      ], silent: true
      @graph.reset []
      @graph.edgesOut.should.be.empty

    it "creates edges for target ids", ->
      @graph.reset [
        { _id: "source", targetIds: [ "target" ] }
        { _id: "target" }
      ]
      @graph.edgesIn.should.have.deep.property "target[0]", @graph.get("source")
      @graph.edgesOut.should.have.deep.property "source[0]", @graph.get("target")

    it "creates edges for source ids", ->
      @graph.reset [
        { _id: "target", sourceIds: [ "source" ] }
        { _id: "source" }
      ]
      @graph.edgesIn.should.have.deep.property "target[0]", @graph.get("source")
      @graph.edgesOut.should.have.deep.property "source[0]", @graph.get("target")

  describe "on change:targetIds", ->

    context "edgesIn", ->

      context "adding ids", ->

        beforeEach ->
          @graph.reset [
            { _id: "source" }
            { _id: "target" }
          ], silent: true
          @source = @graph.get "source"
          @target = @graph.get "target"

        it "creates edge for added id", ->
          @source.set "targetIds", [ "target" ]
          @graph.edgesIn.should.have.deep.property "target.length", 1
          @graph.edgesIn.should.have.deep.property "target[0]", @source
        
        it "ignores external ids", ->
          @source.set "targetIds", [ "external" ]
          @graph.edgesIn.should.have.deep.property "target.length", 0

        it "creates edges when target bis added later", ->
          @source.set "targetIds", [ "other" ]
          @graph.add _id: "other"
          @graph.edgesIn.should.have.deep.property "other[0]", @source

      context "removing ids", ->

        it "removes edge for removed id", ->
          @graph.reset [
            { _id: "source", targetIds: [ "target" ] }
            { _id: "target" }
          ], silent: true
          @graph.get("source").set "targetIds", []
          @graph.edgesIn.should.have.deep.property "target.length", 0

        it "does not create edge when node is added later", ->
          @graph.reset [
            { _id: "source", targetIds: [ "target" ] }
          ], silent: true
          @graph.get("source").set "targetIds", []
          @graph.add _id: "target"
          @graph.edgesIn.should.have.deep.property "target.length", 0
          
    context "edgesOut", ->

      context "adding ids", ->

        beforeEach ->
          @graph.reset [
            { _id: "source" }
            { _id: "target" }
          ], silent: true
          @source = @graph.get "source"
          @target = @graph.get "target"

        it "creates edge for added id", ->
          @source.set "targetIds", [ "target" ]
          @graph.edgesOut.should.have.deep.property "source.length", 1
          @graph.edgesOut.should.have.deep.property "source[0]", @target
        
        it "ignores external ids", ->
          @source.set "targetIds", [ "external" ]
          @graph.edgesOut.should.have.deep.property "source.length", 0

        it "creates edges when target is added later", ->
          @source.set "targetIds", [ "other" ]
          @graph.add _id: "other"
          @graph.edgesOut.should.have.deep.property "source[0]", @graph.get("other")

      context "removing ids", ->

        it "removes edge for removed id", ->
          @graph.reset [
            { _id: "source", targetIds: [ "target" ] }
            { _id: "target" }
          ], silent: true
          @graph.get("source").set "targetIds", []
          @graph.edgesOut.should.have.deep.property "source.length", 0

        it "does not create edge when node is added later", ->
          @graph.reset [
            { _id: "source", targetIds: [ "target" ] }
          ], silent: true
          @graph.get("source").set "targetIds", []
          @graph.add _id: "target"
          @graph.edgesOut.should.have.deep.property "source.length", 0

  describe "on change:sourceIds", ->

    context "edgesIn", ->

      context "adding ids", ->

        beforeEach ->
          @graph.reset [
            { _id: "source" }
            { _id: "target" }
          ], silent: true
          @source = @graph.get "source"
          @target = @graph.get "target"

        it "creates edge for added id", ->
          @target.set "sourceIds", [ "source" ]
          @graph.edgesIn.should.have.deep.property "target.length", 1
          @graph.edgesIn.should.have.deep.property "target[0]", @source
        
        it "ignores external ids", ->
          @target.set "sourceIds", [ "external" ]
          @graph.edgesIn.should.have.deep.property "target.length", 0

        it "creates edges when source is added later", ->
          @target.set "sourceIds", [ "other" ]
          @graph.add _id: "other"
          @graph.edgesIn.should.have.deep.property "target[0]", @graph.get("other")

      context "removing ids", ->

        it "removes edge for removed id", ->
          @graph.reset [
            { _id: "target", sourceIds: [ "source" ] }
            { _id: "source" }
          ], silent: true
          @graph.get("target").set "sourceIds", []
          @graph.edgesIn.should.have.deep.property "target.length", 0

        it "does not create edge when node is added later", ->
          @graph.reset [
            { _id: "target", sourceIds: [ "source" ] }
          ], silent: true
          @graph.get("target").set "sourceIds", []
          @graph.add _id: "source"
          @graph.edgesIn.should.have.deep.property "target.length", 0
          
    context "edgesOut", ->

      context "adding ids", ->

        beforeEach ->
          @graph.reset [
            { _id: "source" }
            { _id: "target" }
          ], silent: true
          @source = @graph.get "source"
          @target = @graph.get "target"

        it "creates edge for added id", ->
          @target.set "sourceIds", [ "source" ]
          @graph.edgesOut.should.have.deep.property "source.length", 1
          @graph.edgesOut.should.have.deep.property "source[0]", @target
        
        it "ignores external ids", ->
          @source.set "sourceIds", [ "external" ]
          @graph.edgesOut.should.have.deep.property "source.length", 0

        it "creates edges when source bis added later", ->
          @target.set "sourceIds", [ "other" ]
          @graph.add _id: "other"
          @graph.edgesOut.should.have.deep.property "other[0]", @target

      context "removing ids", ->

        it "removes edge for removed id", ->
          @graph.reset [
            { _id: "target", sourceIds: [ "source" ] }
            { _id: "source" }
          ], silent: true
          @graph.get("target").set "sourceIds", []
          @graph.edgesOut.should.have.deep.property "source.length", 0

        it "does not create edge when node is added later", ->
          @graph.reset [
            { _id: "target", sourceIds: [ "source" ] }
          ], silent: true
          @graph.get("target").set "sourceIds", []
          @graph.add _id: "source"
          @graph.edgesOut.should.have.deep.property "source.length", 0

  describe "events", ->
  
    context "edge:in:add", ->

      it "is triggered on target", ->
        @graph.reset [
          { _id: "source" }
          { _id: "target" }
        ], silent: true
        source = @graph.get "source"
        target = @graph.get "target"
        spy = sinon.spy()
        target.on "edge:in:add", spy
        target.set "sourceIds", [ "source" ]
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith source: source, target: target

      it "can be silenced", ->
        @graph.reset [ _id: "source" ]
        spy = sinon.spy()
        @graph.on "edge:in:add", spy
        @graph.add { _id: "ghost", sourceIds: [ "source" ] }, silent: true
        spy.should.not.have.been.called

    context "edge:in:remove", ->

      beforeEach ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        @source = @graph.get "source"
        @target = @graph.get "target"

      it "is triggered on target", ->
        spy = sinon.spy()
        @target.on "edge:in:remove", spy
        @source.set "targetIds", []
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith source: @source, target: @target

      it "can be silenced", ->
        spy = sinon.spy()
        @graph.on "edge:in:remove", spy
        @graph.remove "target", silent: true
        spy.should.not.have.been.called

    context "edge:out:add", ->

      it "is triggered on source", ->
        @graph.reset [
          { _id: "source" }
          { _id: "target" }
        ], silent: true
        source = @graph.get "source"
        target = @graph.get "target"
        spy = sinon.spy()
        source.on "edge:out:add", spy
        target.set "sourceIds", [ "source" ]
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith source: source, target: target

      it "can be silenced", ->
        @graph.reset [ _id: "source" ]
        spy = sinon.spy()
        @graph.on "edge:out:add", spy
        @graph.add { _id: "ghost", sourceIds: [ "source" ] }, silent: true
        spy.should.not.have.been.called

    context "edge:out:remove", ->

      beforeEach ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        @source = @graph.get "source"
        @target = @graph.get "target"

      it "is triggered on target", ->
        spy = sinon.spy()
        @source.on "edge:out:remove", spy
        @source.set "targetIds", []
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith source: @source, target: @target

      it "can be silenced", ->
        spy = sinon.spy()
        @graph.on "edge:out:remove", spy
        @graph.remove "target", silent: true
        spy.should.not.have.been.called

  describe "edges()", ->
  
    it "is an empty array by default", ->
      @graph.edges().should.be.an.instanceof Array
      @graph.edges().should.have.length 0

    it "returns edges as vectors", ->
      @graph.reset [
        { _id: "source", targetIds: [ "target" ] }
        { _id: "target" }
      ], silent: true
      source = @graph.get "source"
      target = @graph.get "target"
      @graph.edges().should.eql [
        source: source
        target: target
      ]
    
    context "memoizing", ->
      
      it "reuses edges data", ->
        memo = @graph.edges()
        @graph.edges().should.equal memo

      it "is recreated when a new edge is created", ->
        memo = @graph.edges()
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ]
        @graph.edges().should.have.length 1
      
      it "is recreated when an edge is removed", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        memo = @graph.edges()
        @graph.remove "target"
        @graph.edges().should.have.length 0

  describe "roots()", ->
  
    it "is an empty array by default", ->
      @graph.roots().should.be.an.instanceof Array
      @graph.roots().should.have.length 0

    it "returns root nodes", ->
      @graph.reset [
        { _id: "source", targetIds: [ "target" ] }
        { _id: "target" }
      ], silent: true
      source = @graph.get "source"
      @graph.roots().should.eql [ source ]
    
    context "memoizing", ->
      
      it "reuses roots data", ->
        memo = @graph.roots()
        @graph.roots().should.equal memo

      it "is recreated on reset", ->
        memo = @graph.roots()
        @graph.reset [ _id: "node" ]
        @graph.roots().should.have.length 1

      it "is recreated when a node is added", ->
        memo = @graph.roots()
        @graph.add _id: "node"
        @graph.roots().should.have.length 1

      it "is recreated when a node is removed", ->
        @graph.reset [ _id: "node" ], silent: true
        memo = @graph.roots()
        @graph.remove "node"
        @graph.roots().should.have.length 0

      it "is recreated when a new edge is created", ->
        memo = @graph.roots()
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ]
        @graph.roots().should.have.length 1
      
      it "is recreated when an edge is removed", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        memo = @graph.roots()
        @graph.get("source").set "targetIds", []
        @graph.roots().should.have.length 2

  describe "leaves()", ->
  
    it "is an empty array by default", ->
      @graph.leaves().should.be.an.instanceof Array
      @graph.leaves().should.have.length 0

    it "returns leave nodes", ->
      @graph.reset [
        { _id: "source", targetIds: [ "target" ] }
        { _id: "target" }
      ], silent: true
      target = @graph.get "target"
      @graph.leaves().should.eql [ target ]
    
    context "memoizing", ->
      
      it "reuses leaves data", ->
        memo = @graph.leaves()
        @graph.leaves().should.equal memo

      it "is recreated on reset", ->
        memo = @graph.leaves()
        @graph.reset [ _id: "node" ]
        @graph.leaves().should.have.length 1

      it "is recreated when a node is added", ->
        memo = @graph.leaves()
        @graph.add _id: "node"
        @graph.leaves().should.have.length 1

      it "is recreated when a node is removed", ->
        @graph.reset [ _id: "node" ], silent: true
        memo = @graph.leaves()
        @graph.remove "node"
        @graph.leaves().should.have.length 0

      it "is recreated when a new edge is created", ->
        memo = @graph.leaves()
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ]
        @graph.leaves().should.have.length 1
      
      it "is recreated when an edge is removed", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        memo = @graph.leaves()
        @graph.get("source").set "targetIds", []
        @graph.leaves().should.have.length 2

  describe "breadthFirstOut()", ->

    beforeEach ->
      @callback = sinon.spy()
  
    it "invokes callback for every node", ->
      @graph.reset [
        { _id: "node_1" }
        { _id: "node_2" }
      ], silent: true
      node_1 = @graph.get "node_1"
      node_2 = @graph.get "node_2"
      @graph.breadthFirstOut @callback 
      @callback.should.have.been.calledTwice
      @callback.should.always.have.been.calledOn @graph
      @callback.firstCall.should.have.been.calledWith node_1
      @callback.secondCall.should.have.been.calledWith node_2

    it "invokes callback breadth first", ->
      @graph.reset [
        { _id: "root", targetIds: [ "child_1", "child_2" ] }
        { _id: "child_1", targetIds: [ "child_of_child"] }
        { _id: "child_2" }
        { _id: "child_of_child" }
      ], silent: true
      @graph.breadthFirstOut @callback 
      @callback.getCall(0).should.have.deep.property "args[0].id", "root"
      @callback.getCall(1).should.have.deep.property "args[0].id", "child_1"
      @callback.getCall(2).should.have.deep.property "args[0].id", "child_2"
      @callback.getCall(3).should.have.deep.property "args[0].id", "child_of_child"

    it "invokes callback only once per node", ->
      @graph.reset [
        { _id: "root", targetIds: [ "child_1", "child_2" ] }
        { _id: "child_1", targetIds: [ "child_of_child"] }
        { _id: "child_2", targetIds: [ "child_of_child"] }
        { _id: "child_of_child" }
      ], silent: true
      @graph.breadthFirstOut @callback 
      @callback.should.have.property "callCount", 4
