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
      @digraph.nodes.should.have.lengthOf 0

    it "recreates graph", ->
      @digraph.reset [ { id: 1 } ]
      @digraph.reset [ { id: 3 }, { id: 2 } ]
      @digraph.nodes.should.have.lengthOf 2

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
        @digraph.nodes.should.have.lengthOf 1
        @digraph.nodes[0].should.have.property "id", 1
        @digraph.nodes[0].should.have.property "label", "foo"

      it "uses identifier method", ->
        @digraph.options.id = (d) -> d.label
        @digraph.reset [ {id: 1, label: "foo" }, {id: 2, label: "foo"} ]
        @digraph.nodes.should.have.lengthOf 1

    context "updating relations", ->

      it "creates references to child nodes", ->
        parent =
          id: "parent"
          child_ids: [ "child" ]
        child =
          id: "child"
        @digraph.reset [ parent, child ]
        parent = node for node in @digraph.nodes when node.id is "parent"
        child  = node for node in @digraph.nodes when node.id is "child"
        parent.should.have.property("children").that.is.an "array"
        parent.should.have.deep.property "children[0]", child

      it "creates references to parent nodes", ->
        parent =
          id: "parent"
        child =
          id: "child"
          parent_ids: [ "parent"]
        @digraph.reset [ parent, child ]
        parent = node for node in @digraph.nodes when node.id is "parent"
        child  = node for node in @digraph.nodes when node.id is "child"
        child.should.have.property("parents").that.is.an "array"
        child.should.have.deep.property "parents[0]", parent

      it "defaults relations to null", ->
        @digraph.reset [ id: 1 ]
        @digraph.nodes[0].should.have.property "children", null
        @digraph.nodes[0].should.have.property "parents", null

    context "creating edges", ->

      it "creates edges for child relations", ->
        parent =
          id: "parent"
          child_ids: [ "child_1", "child_2" ]
        child1 = id: "child_1"
        child2 = id: "child_2"
        @digraph.reset [ parent, child1, child2 ]
        @digraph.edges.should.have.lengthOf 2
        relation1 = edge for edge in @digraph.edges when edge.target.id is "child_1"
        relation1.should.have.deep.property "source.id",  "parent"
        relation2 = edge for edge in @digraph.edges when edge.target.id is "child_2"
        relation2.should.have.deep.property "source.id",  "parent"
        
      it "creates edges for parent relations", ->
        parent = id: "parent"
        child1 =
          id: "child_1"
          parent_ids: [ "parent" ]
        child2 =
          id: "child_2"
          parent_ids: [ "parent" ]
        @digraph.reset [ parent, child1, child2 ]
        @digraph.edges.should.have.lengthOf 2
        relation1 = edge for edge in @digraph.edges when edge.target.id is "child_1"
        relation1.should.have.deep.property "source.id",  "parent"
        relation2 = edge for edge in @digraph.edges when edge.target.id is "child_2"
        relation2.should.have.deep.property "source.id",  "parent"
        
      it "skips relations to external nodes", ->
        node =
          id: "node"
          parent_ids: [ "outer_1" ]
          child_ids:  [ "outer_2" ]
        @digraph.reset [ node ]
        @digraph.edges.should.have.lengthOf 0

    context "creating selections", ->

      it "references nodes that do not have a parent as roots", ->
        @digraph.reset [
            { id: 1, child_ids: null }
            { id: 2, child_ids: [4]  }
            { id: 3, child_ids: null }     
            { id: 4, child_ids: [2]  }
            { id: 5, child_ids: [4]  }
        ]
        ( root.id for root in @digraph.roots ).should.eql [1, 3, 5]
    
    it "references nodes that do not have a child as leaves", ->
      @digraph.reset [
          { id: 1, child_ids: null }
          { id: 2, child_ids: [1] }
          { id: 3, child_ids: [4, 1] }     
          { id: 4, child_ids: [] }
          { id: 5, child_ids: [2, 3, 4] }
      ]
      ( leaf.id for leaf in @digraph.leaves ).should.eql [1, 4]

    it "returns nodes that have multiple parents", ->
      @digraph.reset [
          { id: 1, child_ids: null }
          { id: 2, child_ids: [1] }
          { id: 3, child_ids: [4, 1] }     
          { id: 4, child_ids: [] }
          { id: 5, child_ids: [2, 3, 4] }
      ]
      ( leaf.id for leaf in @digraph.leaves ).should.eql [1, 4]
        
  describe "add()", ->

    beforeEach ->
      @digraph.reset [ id: 1 ]
      
    it "creates missing nodes", ->
      @digraph.add [ id: 2, foo: "bar" ]
      @digraph.nodes.should.have.lengthOf 2
      added = node for node in @digraph.nodes when node.id is 2
      added.should.have.property "foo", "bar"

    it "updates edges", ->
      @digraph.add [ id: 2, child_ids: [ 1 ] ]
      @digraph.edges.should.have.lengthOf 1
      parent = node for node in @digraph.nodes when node.id is 2
      child  = node for node in @digraph.nodes when node.id is 1
      @digraph.edges[0].should.have.property "source", parent
      @digraph.edges[0].should.have.property "target", child

    it "updates nodes", ->
      @digraph.add [ id: 2, child_ids: [ 1 ] ]
      parent = node for node in @digraph.nodes when node.id is 2
      child  = node for node in @digraph.nodes when node.id is 1
      child.should.have.property "parents"
      child.parents[0].should.equal parent

    it "updates selections", ->
      @digraph.add [ id: 2, child_ids: [ 1 ] ]
      parent = node for node in @digraph.nodes when node.id is 2
      child  = node for node in @digraph.nodes when node.id is 1
      @digraph.roots.should.have.lengthOf 1
      @digraph.roots[0].should.equal parent

  describe "remove()", ->

    it "removes nodes", ->
      @digraph.reset [
        { id: 1 }
        { id: 2 }
        { id: 3 }     
      ] 
      @digraph.remove 1, 3
      @digraph.nodes.should.have.lengthOf 1
      @digraph.nodes[0].should.have.property "id", 2

    it "updates edges", ->
      @digraph.reset [
        { id: 1, child_ids: [ 2, 3 ] }
        { id: 2 }
        { id: 3 }     
      ]
      @digraph.remove 2
      @digraph.edges.should.have.lengthOf 1
      @digraph.edges[0].source.should.have.property "id", 1
      @digraph.edges[0].target.should.have.property "id", 3

    it "updates nodes", ->
      @digraph.reset [
        { id: 1, child_ids: [ 2, 3 ] }
        { id: 2 }
        { id: 3 }     
      ]
      @digraph.remove 2
      node_1 = node for node in @digraph.nodes when node.id is 1    
      node_3 = node for node in @digraph.nodes when node.id is 3    
      node_1.children.should.have.lengthOf 1
      node_1.children[0].should.have.property "id", 3
      node_3.parents.should.have.lengthOf 1
      node_3.parents[0].should.have.property "id", 1

    it "updates selections", ->
      @digraph.reset [
        { id: 1, child_ids: [ 2, 3 ] }
        { id: 2, child_ids: [ 3 ] }
        { id: 3, child_ids: [ 4 ] }     
        { id: 4 }     
      ]
      @digraph.remove 1, 4
      @digraph.multiParentNodes.should.have.lengthOf 0
      @digraph.roots.should.have.lengthOf 1
      @digraph.roots[0].should.have.property "id", 2
      @digraph.leaves.should.have.lengthOf 1
      @digraph.leaves[0].should.have.property "id", 3
      
  describe "nodes", ->
  
    it "is empty by default", ->
      @digraph.nodes.should.be.an "array"
      @digraph.nodes.should.have.lengthOf 0

  describe "edges", ->
  
    it "is empty by default", ->
      @digraph.edges.should.be.an "array"
      @digraph.edges.should.have.lengthOf 0

  describe "roots", ->
    
    it "is empty when graph is empty", ->
      @digraph.roots.should.be.an "array"
      @digraph.leaves.should.have.lengthOf 0

  describe "leaves", ->
    
    it "is empty when not applicable", ->
      @digraph.leaves.should.be.an "array"
      @digraph.leaves.should.have.lengthOf 0
 
  describe "multiParentNodes", ->
    
    it "is empty when not applicable", ->
      @digraph.multiParentNodes.should.be.an "array"
      @digraph.multiParentNodes.should.have.lengthOf 0
 
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
        { id: "A", child_ids: [ "D" ]           }
        { id: "B", child_ids: [ "E" ]           }
        { id: "C", child_ids: [ "E" ]           }
        { id: "D", child_ids: [ "F" ]           }
        { id: "E", child_ids: [ "J", "G", "H" ] }
        { id: "F", child_ids: [ "J" ]           }
        { id: "G", child_ids: [ "J" ]           }
        { id: "H", child_ids: [ "K" ]           }
        { id: "J", child_ids: null              }
        { id: "K", child_ids: null              }
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
        { id: "A", child_ids: [ "C" ] }
        { id: "B", child_ids: [ "C" ] }
        { id: "C", child_ids: null    }
        { id: "D", child_ids: null    }
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
          { id: "A", child_ids: [ "D" ]           }
          { id: "B", child_ids: [ "E" ]           }
          { id: "C", child_ids: [ "E" ]           }
          { id: "D", child_ids: [ "F" ]           }
          { id: "E", child_ids: [ "J", "G", "H" ] }
          { id: "F", child_ids: [ "J" ]           }
          { id: "G", child_ids: [ "J" ]           }
          { id: "H", child_ids: [ "K" ]           }
          { id: "J", child_ids: null              }
          { id: "K", child_ids: null              }
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
