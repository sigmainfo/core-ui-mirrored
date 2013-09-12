#= require spec_helper
#= require collections/digraph

describe "Coreon.Collections.Digraph", ->

  beforeEach ->
    @graph = new Coreon.Collections.Digraph

  it "is a Backbone collection", ->
    @graph.should.be.an.instanceof Backbone.Collection

  describe "edges()", ->
  
    it "is empty by default", ->
      @graph.edges().should.be.an.instanceof Array
      @graph.edges().should.have.length 0

      
    it "creates edges from targetIds", ->
      @graph.reset [
        { id: "source", targetIds: [ "target" ] }
        { id: "target" }
      ], silent: true
      @graph.edges().should.have.length 1
      @graph.edges().should.have.deep.property "[0].source.id", "source"
      @graph.edges().should.have.deep.property "[0].target.id", "target"

    it "creates edges from sourceIds", ->
      @graph.reset [
        { id: "source" }
        { id: "target", sourceIds: [ "source" ]}
      ], silent: true
      @graph.edges().should.have.length 1
      @graph.edges().should.have.deep.property "[0].source.id", "source"
      @graph.edges().should.have.deep.property "[0].target.id", "target"

    it "ignores target to outer nodes", ->
      @graph.reset [
        id: "source", targetIds: [ "outer" ]
      ], silent: true
      @graph.edges().should.be.empty

    it "does not create duplicates", ->
      @graph.reset [
        { id: "source", targetIds: [ "target", "target" ] }
        { id: "target", sourceIds: [ "source", "source" ]}
      ], silent: true
      @graph.edges().should.have.length 1

    it "can be configured", ->
      @graph.reset [
        { id: "source_1", outIds: [ "target_1" ] }
        { id: "target_1" }
        { id: "source_2" }
        { id: "target_2", inIds: [ "source_2" ] }
      ], silent: true
      @graph.initialize [], sourceIds: "inIds", targetIds: "outIds"
      @graph.edges().should.have.length 2
      @graph.edges().should.have.deep.property "[0].source.id", "source_1"
      @graph.edges().should.have.deep.property "[1].source.id", "source_2"
  
    context "memoizing", ->
      
      it "always returns a copy", ->
        @graph.reset [
          { id: "source", targetIds: [ "target" ] }
          { id: "target" }
        ], silent: true
        @graph.edges().pop()
        @graph.edges().should.have.length 1

      it "is reevaluated after add", ->
        @graph.reset [
          { id: "source", targetIds: [ "target" ] }
        ], silent: true
        @graph.edges()
        @graph.add id: "target"
        @graph.edges().should.have.length 1

      it "is reevaluated after remove", ->
        @graph.reset [
          { id: "source", targetIds: [ "target" ] }
          { id: "target" }
        ], silent: true
        @graph.edges()
        @graph.remove "target"
        @graph.edges().should.have.length 0

      it "is reevaluated after reset", ->
        @graph.edges()
        @graph.reset [
          { id: "source", targetIds: [ "target" ] }
          { id: "target" }
        ]
        @graph.edges().should.have.length 1

      it "is reevaluated after change of targetIds", ->
        @graph.reset [
          { id: "source" }
          { id: "target" }
        ], silent: true
        @graph.edges()
        @graph.get("source").set "targetIds", [ "target" ]
        @graph.edges().should.have.length 1
        
      it "is reevaluated after change of sourceIds", ->
        @graph.reset [
          { id: "source" }
          { id: "target" }
        ], silent: true
        @graph.edges()
        @graph.get("target").set "sourceIds", [ "source" ]
        @graph.edges().should.have.length 1

  describe "edgesIn()", ->
  
    it "filters edges by target", ->
      @graph.reset [
        { id: "source_1", targetIds: [ "target_1" ] }
        { id: "source_2", targetIds: [ "target_2" ] }
        { id: "target_1" }
        { id: "target_2" }
      ], silent: true
      target = @graph.get "target_1"
      @graph.edgesIn(target).should.have.length 1
      @graph.edgesIn(target).should.have.deep.property "[0].source.id", "source_1"
      @graph.edgesIn(target).should.have.deep.property "[0].target.id", "target_1"

    it "accepts id as argument", ->
      @graph.reset [
        { id: "source_1", targetIds: [ "target_1" ] }
        { id: "source_2", targetIds: [ "target_2" ] }
        { id: "target_1" }
        { id: "target_2" }
      ], silent: true
      @graph.edgesIn("target_2").should.have.length 1
      @graph.edgesIn("target_2").should.have.deep.property "[0].source.id", "source_2"
      @graph.edgesIn("target_2").should.have.deep.property "[0].target.id", "target_2"

    it "returns empty set when no matches are found", ->
      @graph.edgesIn("xxx").should.have.length 0
      
  describe "edgesOut()", ->
  
    it "filters edges by target", ->
      @graph.reset [
        { id: "source_1", targetIds: [ "target_1" ] }
        { id: "source_2", targetIds: [ "target_2" ] }
        { id: "target_1" }
        { id: "target_2" }
      ], silent: true
      source = @graph.get "source_1"
      @graph.edgesOut(source).should.have.length 1
      @graph.edgesOut(source).should.have.deep.property "[0].source.id", "source_1"
      @graph.edgesOut(source).should.have.deep.property "[0].target.id", "target_1"

    it "accepts id as argument", ->
      @graph.reset [
        { id: "source_1", targetIds: [ "target_1" ] }
        { id: "source_2", targetIds: [ "target_2" ] }
        { id: "target_1" }
        { id: "target_2" }
      ], silent: true
      @graph.edgesOut("source_2").should.have.length 1
      @graph.edgesOut("source_2").should.have.deep.property "[0].source.id", "source_2"
      @graph.edgesOut("source_2").should.have.deep.property "[0].target.id", "target_2"

    it "returns empty set when no matches are found", ->
      @graph.edgesOut("xxx").should.have.length 0

  describe "roots()", ->
  
    it "is empty by default", ->
      @graph.roots().should.be.an.instanceof Array
      @graph.roots().should.have.length 0

    it "filters models that do not have an incoming edge", ->
      @graph.reset [
        { id: "source", targetIds: [ "target" ] }
        { id: "target" }
      ], silent: true
      @graph.roots().should.have.length 1
      @graph.roots().should.have.deep.property "[0].id", "source"

    it "filters roots that are connected to given nodes", ->
      @graph.reset [
        { id: "source_1", targetIds: [ "target_1" ] }
        { id: "target_1" }
        { id: "source_2", targetIds: [ "target_2" ] }
        { id: "target_2" }
      ], silent: true
      @graph.roots("target_1").should.have.length 1
      @graph.roots().should.have.deep.property "[0].id", "source_1"

  describe "leaves()", ->
  
    it "is empty by default", ->
      @graph.leaves().should.be.an.instanceof Array
      @graph.leaves().should.have.length 0

    it "filters models that do not have an incoming edge", ->
      @graph.reset [
        { id: "source", targetIds: [ "target" ] }
        { id: "target" }
      ], silent: true
      @graph.leaves().should.have.length 1
      @graph.leaves().should.have.deep.property "[0].id", "target"

    it "filters leaves that are connected to given nodes", ->
      @graph.reset [
        { id: "source_1", targetIds: [ "target_1" ] }
        { id: "target_1" }
        { id: "source_2", targetIds: [ "target_2" ] }
        { id: "target_2" }
      ], silent: true
      @graph.leaves("source_1").should.have.length 1
      @graph.leaves().should.have.deep.property "[0].id", "target_1"

  describe "breadthFirstIn()", ->

    beforeEach ->
      @callback = sinon.spy()
  
    it "invokes callback for every node", ->
      @graph.reset [
        { id: "node_1" }
        { id: "node_2" }
      ], silent: true
      node_1 = @graph.get "node_1"
      node_2 = @graph.get "node_2"
      @graph.breadthFirstIn @callback 
      @callback.should.have.been.calledTwice
      @callback.should.always.have.been.calledOn @graph
      @callback.firstCall.should.have.been.calledWith node_1
      @callback.secondCall.should.have.been.calledWith node_2

    it "invokes callback breadth first", ->
      @graph.reset [
        { id: "root", targetIds: [ "child_1", "child_2" ] }
        { id: "child_1", targetIds: [ "child_of_child"] }
        { id: "child_2" }
        { id: "child_of_child" }
      ], silent: true
      @graph.breadthFirstIn @callback 
      @callback.getCall(0).should.have.deep.property "args[0].id", "root"
      @callback.getCall(1).should.have.deep.property "args[0].id", "child_1"
      @callback.getCall(2).should.have.deep.property "args[0].id", "child_2"
      @callback.getCall(3).should.have.deep.property "args[0].id", "child_of_child"

    it "invokes callback only once per node", ->
      @graph.reset [
        { id: "root", targetIds: [ "child_1", "child_2" ] }
        { id: "child_1", targetIds: [ "child_of_child"] }
        { id: "child_2", targetIds: [ "child_of_child"] }
        { id: "child_of_child" }
      ], silent: true
      @graph.breadthFirstIn @callback 
      @callback.should.have.property "callCount", 4

    it "takes starting nodes as an option", ->
      @graph.reset [
        { id: "root", targetIds: [ "child" ] }
        { id: "child", targetIds: [ "child_of_child"] }
        { id: "child_of_child" }
      ], silent: true
      @graph.breadthFirstIn @callback, start: "child"
      @callback.should.have.been.calledTwice
      @callback.should.not.have.been.calledWith @graph.get "root"

  describe "breadthFirstOut()", ->

    beforeEach ->
      @callback = sinon.spy()
  
    it "invokes callback for every node", ->
      @graph.reset [
        { id: "node_1" }
        { id: "node_2" }
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
        { id: "leaf", sourceIds: [ "parent_1", "parent_2" ] }
        { id: "parent_1", sourceIds: [ "parent_of_parent"] }
        { id: "parent_2" }
        { id: "parent_of_parent" }
      ], silent: true
      @graph.breadthFirstOut @callback 
      @callback.getCall(0).should.have.deep.property "args[0].id", "leaf"
      @callback.getCall(1).should.have.deep.property "args[0].id", "parent_1"
      @callback.getCall(2).should.have.deep.property "args[0].id", "parent_2"
      @callback.getCall(3).should.have.deep.property "args[0].id", "parent_of_parent"

    it "invokes callback only once per node", ->
      @graph.reset [
        { id: "leaf", sourceIds: [ "parent_1", "parent_2" ] }
        { id: "parent_1", sourceIds: [ "parent_of_parent"] }
        { id: "parent_2", sourceIds: [ "parent_of_parent"] }
        { id: "parent_of_parent" }
      ], silent: true
      @graph.breadthFirstOut @callback 
      @callback.should.have.property "callCount", 4

    it "takes starting nodes as argument", ->
      @graph.reset [
        { id: "leaf", sourceIds: [ "parent" ] }
        { id: "parent", sourceIds: [ "parent_of_parent"] }
        { id: "parent_of_parent" }
      ], silent: true
      @graph.breadthFirstOut @callback, start: "parent"
      @callback.should.have.been.calledTwice
      @callback.should.not.have.been.calledWith @graph.get "leaf"
