#= require spec_helper
#= require data/digraph

describe "Coreon.Data.Digraph", ->

  beforeEach ->
    @digraph = new Coreon.Data.Digraph

  describe "initialize()", ->
    
    it "resets graph", ->
      @digraph.reset = sinon.spy()
      @digraph.initialize [ id: "abc" ]
      @digraph.reset.should.have.been.calledOnce
      @digraph.reset.should.have.been.calledWith [ id: "abc" ]

    it "takes options", ->
      factory = (datum) -> "Hello #{datum}!"
      @digraph.initialize [], factory: factory
      @digraph.options.factory("Nobody").should.equal "Hello Nobody!"


  describe "reset()", ->

    it "clears graph by default", ->
      @digraph.reset [ { id: 1 }, { id: 2 } ]
      @digraph.reset()
      @digraph.nodes.should.have.length 0

    it "recreates graph", ->
      @digraph.reset [ { id: 1 } ]
      @digraph.reset [ { id: 3 }, { id: 2 } ]
      @digraph.nodes.should.have.length 2

    context "creating datum nodes", ->
      
      it "creates copy of data", ->
        data = [ { id: 1 }, { id: 2 } ]
        @digraph.reset data
        ids = ( node.id for node in @digraph.nodes )
        ids.should.include 1
        ids.should.include 2
        @digraph.nodes[0].should.not.equal data[0]

      it "uses factory method", ->
        @digraph.options.factory = (id, d) -> name: d.id
        @digraph.reset [ {id: "foo" }]
        @digraph.nodes[0].should.have.property "name", "foo"

      it "does not create duplicates", ->
        @digraph.reset [ {id: 1, label: "foo" }, {id: 1, label: "bar"} ]
        @digraph.nodes.should.have.length 1
        @digraph.nodes[0].should.have.property "id", 1
        @digraph.nodes[0].should.have.property "label", "foo"

      it "uses identifier method", ->
        @digraph.options.id = (d) -> d.label
        @digraph.reset [ {id: 1, label: "foo" }, {id: 2, label: "foo"} ]
        @digraph.nodes.should.have.length 1

    context "creating child nodes", ->

      it "creates entries for children", ->
        @digraph.options.factory = sinon.stub().returnsArg 0
        @digraph.reset [ id: 1, children: [ 2, 3 ] ]
        @digraph.nodes.should.eql [ 1, 2, 3 ]
        
      it "uses walker method", ->
        @digraph.options.factory = sinon.stub().returnsArg 0
        @digraph.options.down = (d) -> d.kidz
        @digraph.reset [ id: 1, kidz: [ 2, 3 ] ]
        @digraph.nodes.should.eql [ 1, 2, 3 ]

      it "skips duplicates prefering data", ->
        @digraph.reset [
          { id: 1, children: [ 2, 3 ] }
          { id: 2, children: [ 3, 4 ], label: "Nobody" }
        ]
        @digraph.nodes.should.have.length 4
        dup = node for node in @digraph.nodes when node.id is 2
        dup.should.have.property "label", "Nobody"

    context "creating parent nodes", ->
      
      it "creates entries for parents", ->
        @digraph.options.factory = sinon.stub().returnsArg 0
        @digraph.reset [ id: 1, parents: [ 2, 3 ] ]
        @digraph.nodes.should.eql [ 1, 2, 3 ]
        
      it "uses walker method", ->
        @digraph.options.factory = sinon.stub().returnsArg 0
        @digraph.options.up = (d) -> d.mommies
        @digraph.reset [ id: 1, mommies: [ 2, 3 ] ]
        @digraph.nodes.should.eql [ 1, 2, 3 ]

      it "skips duplicates prefering data", ->
        @digraph.reset [
          { id: 1, parents: [ 2, 3 ] }
          { id: 2, parents: [ 3, 4 ], label: "Nobody" }
        ]
        @digraph.nodes.should.have.length 4
        dup = node for node in @digraph.nodes when node.id is 2
        dup.should.have.property "label", "Nobody"

    context "creating sibling nodes", ->
      
      it "creates entries for siblings", ->
        @digraph.options.factory = (id, datum) ->
          if id is 2 then id: 2, children: [3, 4] else id: id
        @digraph.reset [ { id: 1, parents: [ 2 ] } ]
        ids = ( node.id for node in @digraph.nodes )
        ids.should.contain 3
        ids.should.contain 4
        
      it "uses walker method", ->
        @digraph.options.factory = (id, datum) ->
          if id is 2 then id: 2, kidz: [3, 4] else id: id
        @digraph.options.up = (d) -> d.mommies
        @digraph.options.down = (d) -> d.kidz
        @digraph.reset [ { id: 1, mommies: [ 2 ] } ]
        ids = ( node.id for node in @digraph.nodes )
        ids.should.contain 3
        ids.should.contain 4
        
      it "skips duplicates prefering data", ->
        @digraph.options.factory = (id, datum) ->
          if id is 2 then id: 2, children: [3, 4] else datum or id: id
        @digraph.reset [
          { id: 1, parents: [ 2 ] }
          { id: 3, label: "Nobody" }
        ]
        @digraph.nodes.should.have.length 4
        dup = node for node in @digraph.nodes when node.id is 3
        dup.should.have.property "label", "Nobody"

    context "updating relations", ->

      it "references child nodes", ->
        child = id: 2
        @digraph.options.factory = (id, datum) ->
          switch id
            when 2 then child
            else datum
        @digraph.reset [ id: 1, children: [ 2 ] ]
        parent = node for node in @digraph.nodes when node.id is 1
        parent.should.have.property("children").that.is.an "array"
        parent.should.have.deep.property "children[0]", child
      
      it "references parent nodes", ->
        parent = id: 1, children: [ 2 ]
        @digraph.options.factory = (id, datum) ->
          switch id
            when 1 then parent
            else id: id
        @digraph.reset [ parent ]
        child = node for node in @digraph.nodes when node.id is 2
        child.should.have.property("parents").that.is.an "array"
        child.should.have.deep.property "parents[0]", parent

      it "defaults relations to null", ->
        @digraph.reset [ id: 1 ]
        @digraph.nodes[0].should.have.property "children", null
        @digraph.nodes[0].should.have.property "parents", null

    context "creating edges", ->

      it "creates edges for child relations", ->
        @digraph.options.factory = (id, datum) -> datum or id: id
        @digraph.reset [ id: 1, children: [ 2, 3 ] ]
        @digraph.edges.should.have.length 2
        relation = edge for edge in @digraph.edges when edge.target.id is 2
        relation.should.exist
        relation.should.have.deep.property "source.id",  1
        
      it "skips relations to external nodes", ->
        @digraph.options.factory = (id, datum) ->
          if id is 2 then id: 2, children: [ 3 ] else datum
        @digraph.reset [ id: 1, children: [ 2 ] ]
        @digraph.edges.should.have.length 1
        @digraph.edges[0].should.have.deep.property "source.id", 1
        @digraph.edges[0].should.have.deep.property "target.id", 2

    context "creating selections", ->

      it "references nodes that do not have a parent as roots", ->
        @digraph.reset [
            { id: 1, children: null }
            { id: 2, children: [4]  }
            { id: 3, children: null }     
            { id: 4, children: [2]  }
            { id: 5, children: [4]  }
        ]
        ( root.id for root in @digraph.roots ).should.eql [1, 3, 5]
    
    it "references nodes that do not have a child as leaves", ->
      @digraph.reset [
          { id: 1, children: null }
          { id: 2, children: [1] }
          { id: 3, children: [4, 1] }     
          { id: 4, children: [] }
          { id: 5, children: [2, 3, 4] }
      ]
      ( leaf.id for leaf in @digraph.leaves ).should.eql [1, 4]

    it "returns nodes that have multiple parents", ->
      @digraph.reset [
          { id: 1, children: null }
          { id: 2, children: [1] }
          { id: 3, children: [4, 1] }     
          { id: 4, children: [] }
          { id: 5, children: [2, 3, 4] }
      ]
      ( leaf.id for leaf in @digraph.leaves ).should.eql [1, 4]
        
  describe "add()", ->

    beforeEach ->
      @digraph.reset [ id: 1 ]
      
    it "creates missing nodes", ->
      @digraph.add [ id: 2, foo: "bar" ]
      @digraph.nodes.should.have.length 2
      added = node for node in @digraph.nodes when node.id is 2
      added.should.have.property "foo", "bar"

    it "updates edges", ->
      @digraph.add [ id: 2, children: [ 1 ] ]
      @digraph.edges.should.have.length 1
      parent = node for node in @digraph.nodes when node.id is 2
      child  = node for node in @digraph.nodes when node.id is 1
      @digraph.edges[0].should.have.property "source", parent
      @digraph.edges[0].should.have.property "target", child

    it "updates nodes", ->
      @digraph.add [ id: 2, children: [ 1 ] ]
      parent = node for node in @digraph.nodes when node.id is 2
      child  = node for node in @digraph.nodes when node.id is 1
      child.should.have.property "parents"
      child.parents[0].should.equal parent

    it "updates selections", ->
      @digraph.add [ id: 2, children: [ 1 ] ]
      parent = node for node in @digraph.nodes when node.id is 2
      child  = node for node in @digraph.nodes when node.id is 1
      @digraph.roots.should.have.length 1
      @digraph.roots[0].should.equal parent

  describe "remove()", ->
    
    it "removes nodes", ->
      fail()

    it "updates edges"
    it "updates nodes"
    it "updates selections"
      
    

  describe "nodes", ->
  
    it "is empty by default", ->
      @digraph.nodes.should.be.an "array"
      @digraph.nodes.should.have.length 0

  describe "edges", ->
  
    it "is empty by default", ->
      @digraph.edges.should.be.an "array"
      @digraph.edges.should.have.length 0

  describe "roots", ->
    
    it "is empty when graph is empty", ->
      @digraph.roots.should.be.an "array"
      @digraph.leaves.should.have.length 0

  describe "leaves", ->
    
    it "is empty when not applicable", ->
      @digraph.leaves.should.be.an "array"
      @digraph.leaves.should.have.length 0
 
  describe "multiParentNodes", ->
    
    it "is empty when not applicable", ->
      @digraph.multiParentNodes.should.be.an "array"
      @digraph.multiParentNodes.should.have.length 0
 
  describe "down()", ->

    beforeEach ->
      # create following graph:
      #
      # A   B   C
      # |    \ /
      # D     E
      # |   / | \
      # F  |  G  H
      #  \ | /   |
      #    J     K
      #
      @digraph.reset [
        { id: "A", children: [ "D" ]           }
        { id: "B", children: [ "E" ]           }
        { id: "C", children: [ "E" ]           }
        { id: "D", children: [ "F" ]           }
        { id: "E", children: [ "J", "G", "H" ] }
        { id: "F", children: [ "J" ]           }
        { id: "G", children: [ "J" ]           }
        { id: "H", children: [ "K" ]           }
        { id: "J", children: null              }
        { id: "K", children: null              }
      ]
      @walker = sinon.spy()

    it "invokes callback on root node first", ->
      root = node for node in @digraph.nodes when node.id is "B"
      @digraph.down root, @walker
      @walker.firstCall.args[0].should.have.property "id", "B"

    it "can start on multiple root nodes", ->
      roots = []
      roots.push node for node in @digraph.nodes when "DE".indexOf(node.id) > -1
      @digraph.down roots..., @walker
      ( arg[0].id for arg in @walker.args[0..1] ).join("->").should.equal "D->E" 

    it "defaults start nodes to root nodes", ->
      @digraph.down @walker
      ( arg[0].id for arg in @walker.args[0..2] ).join("->").should.equal "A->B->C"
    
    it "walks down the graph invoking the callback once for every connected node", ->
      root = node for node in @digraph.nodes when node.id is "A"
      @digraph.down root, @walker
      ( arg[0].id for arg in @walker.args ).join("->").should.equal "A->D->F->J"

    it "walks the graph breadth first invoking the callback only once per node", ->
      @digraph.down @walker
      ( arg[0].id for arg in @walker.args ).join("->").should.equal "A->B->C->D->E->F->J->G->H->K"

    it "does not revisit start nodes", ->
      rootA = node for node in @digraph.nodes when node.id is "A"
      rootB = node for node in @digraph.nodes when node.id is "B"
      rootA.children.push rootB
      @digraph.down rootA, rootB, @walker
      ( arg[0].id for arg in @walker.args ).join("->").should.equal "A->B->D->E->F->J->G->H->K"

    it "cleans up intermediate state property", ->
      @digraph.down @walker
      @digraph.nodes[5].should.not.have.property "_visited"

    it "cleans up on error", ->
      try
        beast = node for node in @digraph.nodes when node.id is "G"
        @walker = (node) ->
          throw new Error "666 is the number of the beast!" if node is beast
        @digraph.down @walker
      finally
        @digraph.nodes[5].should.not.have.property "_visited"

  describe "tree()", ->
    
    it "returns bare root node for empty graph", ->
      @digraph.tree().should.eql
        treeUp: []
        treeDown: []

    it "attaches graph roots to tree root", ->
      @digraph.reset [
        { id: "A", children: [ "C" ] }
        { id: "B", children: [ "C" ] }
        { id: "C", children: null    }
        { id: "D", children: null    }
      ]
      root = @digraph.tree()
      ( child.id for child in root.treeDown ).should.eql [ "A", "B", "D" ]
      root.treeDown[0].should.have.deep.property "treeUp[0]", root
      root.treeDown[1].should.have.deep.property "treeUp[0]", root
      root.treeDown[2].should.have.deep.property "treeUp[0]", root

    context "walking graph as a tree structure", ->  
        
      beforeEach ->
        # create following graph:
        #
        # A   B   C
        # |    \ /
        # D     E
        # |   / | \
        # F  |  G  H
        #  \ | /   |
        #    J     K
        #
        @digraph.reset [
          { id: "A", children: [ "D" ]           }
          { id: "B", children: [ "E" ]           }
          { id: "C", children: [ "E" ]           }
          { id: "D", children: [ "F" ]           }
          { id: "E", children: [ "J", "G", "H" ] }
          { id: "F", children: [ "J" ]           }
          { id: "G", children: [ "J" ]           }
          { id: "H", children: [ "K" ]           }
          { id: "J", children: null              }
          { id: "K", children: null              }
        ]
        @root = @digraph.tree()
        @nodes = {}
        @nodes["B"] = node for node in @root.treeDown when node.id is "B"
        @nodes["C"] = node for node in @root.treeDown when node.id is "C"
        @nodes["E"] = @nodes["B"].children[0]
        @nodes["G"] = node for node in @nodes["E"].children when node.id is "G"
        @nodes["J"] = @nodes["G"].children[0]

      it "uses most distant parent", ->
        @root.treeUp.should.eql []
        @nodes["B"].should.have.deep.property "treeUp[0]", @root
        @nodes["C"].should.have.deep.property "treeUp[0]", @root
        @nodes["E"].should.have.deep.property "treeUp.length", 1
        @nodes["E"].should.have.deep.property "treeUp[0].id", "C"
        @nodes["G"].should.have.deep.property "treeUp[0].id", "E"
        @nodes["J"].should.have.deep.property "treeUp.length", 1
        @nodes["J"].should.have.deep.property "treeUp[0].id", "G"

      it "removes orphaned children", ->
        @root.should.have.deep.property "treeDown.length", 3
        @nodes["B"].should.have.deep.property "treeDown.length", 0
        @nodes["C"].should.have.deep.property "treeDown.length", 1
        @nodes["C"].should.have.deep.property "treeDown[0].id", "E"
        @nodes["E"].should.have.deep.property "treeDown.length", 2
        @nodes["E"].should.have.deep.property "treeDown[0].id", "G"
        @nodes["E"].should.have.deep.property "treeDown[1].id", "H"
        @nodes["G"].should.have.deep.property "treeDown.length", 1
        @nodes["G"].should.have.deep.property "treeDown[0].id", "J"
        @nodes["J"].should.have.deep.property "treeDown.length", 0
