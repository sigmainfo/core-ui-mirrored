#= require spec_helper
#= require collections/treegraph

describe "Coreon.Collections.Treegraph", ->
  
  beforeEach ->
    @graph = new Coreon.Collections.Treegraph

  it "is a Digraph", ->
    @graph.should.be.an.instanceof Coreon.Collections.Digraph

  describe "tree()", ->
    
    it "returns root node", ->
      @graph.tree().should.eql children: []

    it "accumulates data from models", ->
      @graph.reset [ _id: "node" ], silent: true
      @graph.tree()
      node = @graph.get "node"
      @graph.tree().should.have.deep.property "children[0].id", "node"
      @graph.tree().should.have.deep.property "children[0].node", node
      @graph.tree().should.have.deep.property("children[0].children").with.length 0

    it "creates complete branch downto leaves", ->
      @graph.reset [
        { _id: "parent", targetIds: [ "child" ] }
        { _id: "child", targetIds: [ "child_of_child" ] }
        { _id: "child_of_child" }
      ], silent: true
      @graph.tree().should.have.deep.property "children[0].id", "parent"
      @graph.tree().should.have.deep.property "children[0].children[0].id", "child"
      @graph.tree().should.have.deep.property "children[0].children[0].children[0].id", "child_of_child"

    it "uses longest path for multiparented nodes", ->
      @graph.reset [
        { _id: "parent", targetIds: [ "child", "child_of_child" ] }
        { _id: "child", targetIds: [ "child_of_child" ] }
        { _id: "child_of_child" }
      ], silent: true
      @graph.tree().should.have.deep.property "children[0].children.length", 1
      @graph.tree().should.have.deep.property "children[0].children[0].id", "child"
      @graph.tree().should.have.deep.property "children[0].children[0].children.length", 1
      @graph.tree().should.have.deep.property "children[0].children[0].children[0].id", "child_of_child"

    context "memoizing", ->

      it "reuses tree data", ->
        memo = @graph.tree()
        @graph.tree().should.equal memo

      it "is recreated on reset", ->
        memo = @graph.tree()
        @graph.reset [ _id: "node" ]
        @graph.tree().should.have.deep.property "children[0].id", "node"

      it "is recreated on add", ->
        memo = @graph.tree()
        @graph.add _id: "node"
        @graph.tree().should.have.deep.property "children[0].id", "node"

      it "is recreated on remove", ->
        @graph.reset [ _id: "node" ], silent: true
        memo = @graph.tree()
        @graph.remove "node"
        @graph.tree().should.have.deep.property "children.length", 0

      it "is recreated when an edge was added", ->
        @graph.reset [
          { _id: "source" }
          { _id: "target" }
        ], silent: true
        memo = @graph.tree()
        @graph.get("source").set "targetIds", [ "target" ]
        @graph.tree().should.have.deep.property "children[0].children[0].id", "target"

      it "is recreated when an edge was removed", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        memo = @graph.tree()
        @graph.get("source").set "targetIds", []
        @graph.tree().should.have.deep.property "children.length", 2

        
