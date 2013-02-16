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
        { _id: "source", targetIds: [ "target" ] }
        { _id: "target" }
      ], silent: true
      @graph.edges().should.have.length 1
      @graph.edges().should.have.deep.property "[0].source.id", "source"
      @graph.edges().should.have.deep.property "[0].target.id", "target"

    it "creates edges from sourceIds", ->
      @graph.reset [
        { _id: "source" }
        { _id: "target", sourceIds: [ "source" ]}
      ], silent: true
      @graph.edges().should.have.length 1
      @graph.edges().should.have.deep.property "[0].source.id", "source"
      @graph.edges().should.have.deep.property "[0].target.id", "target"

    it "ignores target to outer nodes", ->
      @graph.reset [
        _id: "source", targetIds: [ "outer" ]
      ], silent: true
      @graph.edges().should.be.empty

    it "does not create duplicates", ->
      @graph.reset [
        { _id: "source", targetIds: [ "target", "target" ] }
        { _id: "target", sourceIds: [ "source", "source" ]}
      ], silent: true
      @graph.edges().should.have.length 1

    it "can be configured", ->
      @graph.reset [
        { _id: "source_1", outIds: [ "target_1" ] }
        { _id: "target_1" }
        { _id: "source_2" }
        { _id: "target_2", inIds: [ "source_2" ] }
      ], silent: true
      @graph.initialize [], sourceIds: "inIds", targetIds: "outIds"
      @graph.edges().should.have.length 2
      @graph.edges().should.have.deep.property "[0].source.id", "source_1"
      @graph.edges().should.have.deep.property "[1].source.id", "source_2"
  
    context "memoizing", ->
      
      it "always returns a copy", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        @graph.edges().pop()
        @graph.edges().should.have.length 1

      it "is reevaluated after add", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
        ], silent: true
        @graph.edges()
        @graph.add _id: "target"
        @graph.edges().should.have.length 1

      it "is reevaluated after remove", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        @graph.edges()
        @graph.remove "target"
        @graph.edges().should.have.length 0

      it "is reevaluated after reset", ->
        @graph.edges()
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ]
        @graph.edges().should.have.length 1

      it "is reevaluated after change of targetIds", ->
        @graph.reset [
          { _id: "source" }
          { _id: "target" }
        ], silent: true
        @graph.edges()
        @graph.get("source").set "targetIds", [ "target" ]
        @graph.edges().should.have.length 1
        
      it "is reevaluated after change of sourceIds", ->
        @graph.reset [
          { _id: "source" }
          { _id: "target" }
        ], silent: true
        @graph.edges()
        @graph.get("target").set "sourceIds", [ "source" ]
        @graph.edges().should.have.length 1
        
      

  describe "edgesIn()", ->
  
    it "filters edges by target", ->
      @graph.reset [
        { _id: "source_1", targetIds: [ "target_1" ] }
        { _id: "source_2", targetIds: [ "target_2" ] }
        { _id: "target_1" }
        { _id: "target_2" }
      ], silent: true
      target = @graph.get "target_1"
      @graph.edgesIn(target).should.have.length 1
      @graph.edgesIn(target).should.have.deep.property "[0].source.id", "source_1"
      @graph.edgesIn(target).should.have.deep.property "[0].target.id", "target_1"

    it "accepts id as argument", ->
      @graph.reset [
        { _id: "source_1", targetIds: [ "target_1" ] }
        { _id: "source_2", targetIds: [ "target_2" ] }
        { _id: "target_1" }
        { _id: "target_2" }
      ], silent: true
      @graph.edgesIn("target_2").should.have.length 1
      @graph.edgesIn("target_2").should.have.deep.property "[0].source.id", "source_2"
      @graph.edgesIn("target_2").should.have.deep.property "[0].target.id", "target_2"

    it "returns empty set when no matches are found", ->
      @graph.edgesIn("xxx").should.have.length 0
      
  describe "edgesOut()", ->
  
    it "filters edges by target", ->
      @graph.reset [
        { _id: "source_1", targetIds: [ "target_1" ] }
        { _id: "source_2", targetIds: [ "target_2" ] }
        { _id: "target_1" }
        { _id: "target_2" }
      ], silent: true
      source = @graph.get "source_1"
      @graph.edgesOut(source).should.have.length 1
      @graph.edgesOut(source).should.have.deep.property "[0].source.id", "source_1"
      @graph.edgesOut(source).should.have.deep.property "[0].target.id", "target_1"

    it "accepts id as argument", ->
      @graph.reset [
        { _id: "source_1", targetIds: [ "target_1" ] }
        { _id: "source_2", targetIds: [ "target_2" ] }
        { _id: "target_1" }
        { _id: "target_2" }
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
        { _id: "source", targetIds: [ "target" ] }
        { _id: "target" }
      ], silent: true
      @graph.roots().should.have.length 1
      @graph.roots().should.have.deep.property "[0].id", "source"

  describe "leaves()", ->
  
    it "is empty by default", ->
      @graph.leaves().should.be.an.instanceof Array
      @graph.leaves().should.have.length 0

    it "filters models that do not have an incoming edge", ->
      @graph.reset [
        { _id: "source", targetIds: [ "target" ] }
        { _id: "target" }
      ], silent: true
      @graph.leaves().should.have.length 1
      @graph.leaves().should.have.deep.property "[0].id", "target"

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
