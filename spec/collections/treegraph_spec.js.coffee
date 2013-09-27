#= require spec_helper
#= require collections/treegraph

describe "Coreon.Collections.Treegraph", ->
  
  beforeEach ->
    @graph = new Coreon.Collections.Treegraph
    Coreon.application = repository: ->
      id: "my-repo"
      get: -> "MY REPO"

  afterEach ->
    delete Coreon.application

  it "is a Digraph", ->
    @graph.should.be.an.instanceof Coreon.Collections.Digraph

  describe "tree()", ->

    describe "root", ->
    
     it "returns root node", ->
        Coreon.application.repository = ->
          id: "repo-123"
          get: (attr) -> "Repo 123" if attr is "name"
        @graph.tree().root.should.eql
          id: "repo-123"
          label: "Repo 123"
          root: yes
          children: []

     it "accumulates data from models", ->
        @graph.reset [
          id: "123"
          label: "node"
          hit: yes
          expandedIn: yes
          expandedOut: yes
        ], silent: true
        node = @graph.get "123"
        @graph.tree().should.have.deep.property "root.children[0].id", "123"
        @graph.tree().should.have.deep.property "root.children[0].label", "node"
        @graph.tree().should.have.deep.property "root.children[0].hit", yes
        @graph.tree().should.have.deep.property "root.children[0].expandedIn", yes
        @graph.tree().should.have.deep.property "root.children[0].expandedOut", yes
        @graph.tree().should.have.deep.property("root.children[0].children").with.length 0

     it "identifies leaf nodes", ->
        @graph.reset [ subconcept_ids: [] ]
        @graph.tree().should.have.deep.property "root.children[0].leaf", yes
        @graph.reset [ subconcept_ids: [ "child" ] ]
        @graph.tree().should.have.deep.property "root.children[0].leaf", no

     it "defaults hit attribute to false", ->
        @graph.reset [ id: "123" ], silent: true
        node = @graph.get "123"
        @graph.tree().root.children[0].hit.should.be.false

     it "defaults expansion states to false", ->
        @graph.reset [ id: "123" ], silent: true
        node = @graph.get "123"
        @graph.tree().root.children[0].expandedIn.should.be.false
        @graph.tree().root.children[0].expandedOut.should.be.false

     it "creates complete branch downto leaves", ->
        @graph.reset [
          { id: "parent", targetIds: [ "child" ] }
          { id: "child", targetIds: [ "child_of_child" ] }
          { id: "child_of_child" }
        ], silent: true
        @graph.tree().should.have.deep.property "root.children[0].id", "parent"
        @graph.tree().should.have.deep.property "root.children[0].children[0].id", "child"
        @graph.tree().should.have.deep.property "root.children[0].children[0].children[0].id", "child_of_child"

     it "uses longest path for multiparented nodes", ->
        @graph.reset [
          { id: "parent", targetIds: [ "child", "child_of_child" ] }
          { id: "child", targetIds: [ "child_of_child" ] }
          { id: "child_of_child" }
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
          { id: "parent", targetIds: [ "child", "child_of_child" ] }
          { id: "child", targetIds: [ "child_of_child" ] }
          { id: "child_of_child" }
        ], silent: true
        @graph.tree().should.have.deep.property "edges.length", 3
        @graph.tree().should.have.deep.property "edges[0].source", @graph.tree().root.children[0]
        @graph.tree().should.have.deep.property "edges[0].target", @graph.tree().root.children[0].children[0]
        
    context "memoizing", ->

     it "reuses tree data", ->
        memo = @graph.tree()
        @graph.tree().should.equal memo

     it "is recreated on reset", ->
        memo = @graph.tree()
        @graph.reset [ id: "node" ]
        @graph.tree().should.have.deep.property "root.children[0].id", "node"

     it "is recreated on add", ->
        memo = @graph.tree()
        @graph.add id: "node"
        @graph.tree().should.have.deep.property "root.children[0].id", "node"

     it "is recreated on remove", ->
        @graph.reset [ id: "node" ], silent: true
        memo = @graph.tree()
        @graph.remove "node"
        @graph.tree().should.have.deep.property "root.children.length", 0

     it "is recreated when an edge was added", ->
        @graph.reset [
          { id: "source" }
          { id: "target" }
        ], silent: true
        memo = @graph.tree()
        @graph.get("source").set "targetIds", [ "target" ]
        @graph.tree().should.have.deep.property "root.children[0].children[0].id", "target"

     it "is recreated when an edge was removed", ->
        @graph.reset [
          { id: "source", targetIds: [ "target" ] }
          { id: "target" }
        ], silent: true
        memo = @graph.tree()
        @graph.get("source").set "targetIds", []
        @graph.tree().should.have.deep.property "root.children.length", 2

   context "datum updates on model changes", ->

     it "updates label", ->
       @graph.reset [
         id: "123"
         label: "before123"
         subconcept_ids: []
       ], silent: true
       node = @graph.get "123"
       @graph.tree()
       node.set "label", "after123"
       @graph.tree().root.children[0].should.have.property "label", "after123"

     it "updates hit status", ->
       @graph.reset [
         hit: null
         subconcept_ids: []
       ], silent: true
       @graph.tree()
       @graph.first().set "hit", { score: "2.67" }
       @graph.tree().root.children[0].should.have.property "hit", yes

     it "updates leaf status", ->
       @graph.reset [ subconcept_ids: [ "child" ] ], silent: true
       @graph.tree()
       @graph.first().set "subconcept_ids", []
       @graph.tree().root.children[0].should.have.property "leaf", yes
