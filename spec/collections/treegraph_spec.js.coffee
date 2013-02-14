#= require spec_helper
#= require collections/treegraph

describe "Coreon.Collections.Treegraph", ->
  
  beforeEach ->
    @graph = new Coreon.Collections.Treegraph

  it "is a Digraph", ->
    @graph.should.be.an.instanceof Coreon.Collections.Digraph

  describe "tree()", ->

    describe "root", ->
    
      it "returns root node", ->
        @graph.tree().root.should.eql children: []

      it "accumulates data from models", ->
        @graph.reset [ _id: "node" ], silent: true
        @graph.tree()
        node = @graph.get "node"
        @graph.tree().should.have.deep.property "root.children[0].id", "node"
        @graph.tree().should.have.deep.property "root.children[0].model", node
        @graph.tree().should.have.deep.property("root.children[0].children").with.length 0

      it "creates complete branch downto leaves", ->
        @graph.reset [
          { _id: "parent", targetIds: [ "child" ] }
          { _id: "child", targetIds: [ "child_of_child" ] }
          { _id: "child_of_child" }
        ], silent: true
        @graph.tree().should.have.deep.property "root.children[0].id", "parent"
        @graph.tree().should.have.deep.property "root.children[0].children[0].id", "child"
        @graph.tree().should.have.deep.property "root.children[0].children[0].children[0].id", "child_of_child"

      it "uses longest path for multiparented nodes", ->
        @graph.reset [
          { _id: "parent", targetIds: [ "child", "child_of_child" ] }
          { _id: "child", targetIds: [ "child_of_child" ] }
          { _id: "child_of_child" }
        ], silent: true
        @graph.tree().should.have.deep.property "root.children[0].children.length", 1
        @graph.tree().should.have.deep.property "root.children[0].children[0].id", "child"
        @graph.tree().should.have.deep.property "root.children[0].children[0].children.length", 1
        @graph.tree().should.have.deep.property "root.children[0].children[0].children[0].id", "child_of_child"

    describe "edges", ->
    
      it "is empty by default", ->
        @graph.tree().should.have.property("edges").with.length 0      

      it "creates data vectors for edges", ->
        @graph.reset [
          { _id: "parent", targetIds: [ "child", "child_of_child" ] }
          { _id: "child", targetIds: [ "child_of_child" ] }
          { _id: "child_of_child" }
        ], silent: true
        console.log @graph.tree().edges
        @graph.tree().should.have.deep.property "edges.length", 3
        @graph.tree().should.have.deep.property "edges[0].source", @graph.tree().root.children[0]
        @graph.tree().should.have.deep.property "edges[0].target", @graph.tree().root.children[0].children[0]
        
    context "memoizing", ->

      it "reuses tree data", ->
        memo = @graph.tree()
        @graph.tree().should.equal memo

      it "is recreated on reset", ->
        memo = @graph.tree()
        @graph.reset [ _id: "node" ]
        @graph.tree().should.have.deep.property "root.children[0].id", "node"

      it "is recreated on add", ->
        memo = @graph.tree()
        @graph.add _id: "node"
        @graph.tree().should.have.deep.property "root.children[0].id", "node"

      it "is recreated on remove", ->
        @graph.reset [ _id: "node" ], silent: true
        memo = @graph.tree()
        @graph.remove "node"
        @graph.tree().should.have.deep.property "root.children.length", 0

      it "is recreated when an edge was added", ->
        @graph.reset [
          { _id: "source" }
          { _id: "target" }
        ], silent: true
        memo = @graph.tree()
        @graph.get("source").set "targetIds", [ "target" ]
        @graph.tree().should.have.deep.property "root.children[0].children[0].id", "target"

      it "is recreated when an edge was removed", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        memo = @graph.tree()
        @graph.get("source").set "targetIds", []
        @graph.tree().should.have.deep.property "root.children.length", 2

        
