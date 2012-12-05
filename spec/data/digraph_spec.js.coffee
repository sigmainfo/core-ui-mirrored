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

    it "recreates graph", ->
      @digraph.reset [ { id: 1 } ]
      @digraph.reset [ { id: 1 }, { id: 2 } ]
      @digraph.nodes().should.have.length 2

    it "clears graph by default", ->
      @digraph.reset [ { id: 1 }, { id: 2 } ]
      @digraph.reset()
      @digraph.nodes().should.have.length 0
      
  describe "nodes()", ->
  
    it "is empty by default", ->
      @digraph.nodes().should.be.an "array"
      @digraph.nodes().should.have.length 0

    context "creating datum nodes", ->
      
      it "creates copy of data", ->
        data = [ { id: 1 }, { id: 2 } ]
        @digraph.reset data
        ids = ( node.id for node in @digraph.nodes() )
        ids.should.include 1
        ids.should.include 2
        @digraph.nodes()[0].should.not.equal data[0]

      it "uses factory method", ->
        @digraph.options.factory = (id, d) -> name: d.id
        @digraph.reset [ {id: "foo" }]
        @digraph.nodes()[0].should.have.property "name", "foo"

      it "does not create duplicates", ->
        @digraph.reset [ {id: 1, label: "foo" }, {id: 1, label: "bar"} ]
        @digraph.nodes().should.have.length 1
        @digraph.nodes()[0].should.have.property "id", 1
        @digraph.nodes()[0].should.have.property "label", "foo"

      it "uses identifier method", ->
        @digraph.options.id = (d) -> d.label
        @digraph.reset [ {id: 1, label: "foo" }, {id: 2, label: "foo"} ]
        @digraph.nodes().should.have.length 1

    context "creating child nodes", ->

      it "creates entries for children", ->
        @digraph.options.factory = sinon.stub().returnsArg 0
        @digraph.reset [ id: 1, children: [ 2, 3 ] ]
        @digraph.nodes().should.eql [ 1, 2, 3 ]
        
      it "uses walker method", ->
        @digraph.options.factory = sinon.stub().returnsArg 0
        @digraph.options.down = (d) -> d.kidz
        @digraph.reset [ id: 1, kidz: [ 2, 3 ] ]
        @digraph.nodes().should.eql [ 1, 2, 3 ]

      it "skips duplicates prefering data", ->
        @digraph.reset [
          { id: 1, children: [ 2, 3 ] }
          { id: 2, children: [ 3, 4 ], label: "Nobody" }
        ]
        @digraph.nodes().should.have.length 4
        dup = node for node in @digraph.nodes() when node.id is 2
        dup.should.have.property "label", "Nobody"

    context "creating parent nodes", ->
      
      it "creates entries for parents", ->
        @digraph.options.factory = sinon.stub().returnsArg 0
        @digraph.reset [ id: 1, parents: [ 2, 3 ] ]
        @digraph.nodes().should.eql [ 1, 2, 3 ]
        
      it "uses walker method", ->
        @digraph.options.factory = sinon.stub().returnsArg 0
        @digraph.options.up = (d) -> d.mommies
        @digraph.reset [ id: 1, mommies: [ 2, 3 ] ]
        @digraph.nodes().should.eql [ 1, 2, 3 ]

      it "skips duplicates prefering data", ->
        @digraph.reset [
          { id: 1, parents: [ 2, 3 ] }
          { id: 2, parents: [ 3, 4 ], label: "Nobody" }
        ]
        @digraph.nodes().should.have.length 4
        dup = node for node in @digraph.nodes() when node.id is 2
        dup.should.have.property "label", "Nobody"

    context "creating sibling nodes", ->
      
      it "creates entries for siblings", ->
        @digraph.options.factory = (id, datum) ->
          if id is 2 then id: 2, children: [3, 4] else id: id
        @digraph.reset [ { id: 1, parents: [ 2 ] } ]
        ids = ( node.id for node in @digraph.nodes() )
        ids.should.contain 3
        ids.should.contain 4
        
      it "uses walker method", ->
        @digraph.options.factory = (id, datum) ->
          if id is 2 then id: 2, kidz: [3, 4] else id: id
        @digraph.options.up = (d) -> d.mommies
        @digraph.options.down = (d) -> d.kidz
        @digraph.reset [ { id: 1, mommies: [ 2 ] } ]
        ids = ( node.id for node in @digraph.nodes() )
        ids.should.contain 3
        ids.should.contain 4
        
      it "skips duplicates prefering data", ->
        @digraph.options.factory = (id, datum) ->
          if id is 2 then id: 2, children: [3, 4] else datum or id: id
        @digraph.reset [
          { id: 1, parents: [ 2 ] }
          { id: 3, label: "Nobody" }
        ]
        @digraph.nodes().should.have.length 4
        dup = node for node in @digraph.nodes() when node.id is 3
        dup.should.have.property "label", "Nobody"

    context "updating relations", ->

      it "references child nodes", ->
        child = id: 2
        @digraph.options.factory = (id, datum) ->
          switch id
            when 2 then child
            else datum
        @digraph.reset [ id: 1, children: [ 2 ] ]
        parent = node for node in @digraph.nodes() when node.id is 1
        parent.should.have.property("children").that.is.an "array"
        parent.should.have.deep.property "children[0]", child
      
      it "references parent nodes", ->
        parent = id: 1, children: [ 2 ]
        @digraph.options.factory = (id, datum) ->
          switch id
            when 1 then parent
            else id: id
        @digraph.reset [ parent ]
        child = node for node in @digraph.nodes() when node.id is 2
        child.should.have.property("parents").that.is.an "array"
        child.should.have.deep.property "parents[0]", parent

      it "defaults to relations to null", ->
        @digraph.reset [ id: 1 ]
        @digraph.nodes()[0].should.have.property "children", null
        @digraph.nodes()[0].should.have.property "parents", null
        

  describe "edges()", ->
  
    it "is empty by default", ->
      @digraph.edges().should.be.an "array"
      @digraph.edges().should.have.length 0
      
    it "creates edges for child relations", ->
      @digraph.options.factory = (id, datum) -> datum or id: id
      @digraph.reset [ id: 1, children: [ 2, 3 ] ]
      @digraph.edges().should.have.length 2
      relation = edge for edge in @digraph.edges() when edge.target.id is 2
      relation.should.exist
      relation.should.have.deep.property "source.id",  1
      
    it "skips relations to external nodes", ->
      @digraph.options.factory = (id, datum) ->
        if id is 2 then id: 2, children: [ 3 ] else datum
      @digraph.reset [ id: 1, children: [ 2 ] ]
      @digraph.edges().should.have.length 1
      @digraph.edges()[0].should.have.deep.property "source.id", 1
      @digraph.edges()[0].should.have.deep.property "target.id", 2

  describe "roots()", ->
    
    it "is empty when graph is empty", ->
      @digraph.roots().should.be.an "array"
      @digraph.roots().should.have.length 0

    it "returns nodes that do nat have a parent", ->
      @digraph.reset [
          { id: 1, children: null }
          { id: 2, children: [4]  }
          { id: 3, children: null }     
          { id: 4, children: [2]  }
          { id: 5, children: [4]  }
      ]
      ( root.id for root in @digraph.roots() ).should.eql [1, 3, 5]

    it "memoizes selection", ->
      @digraph.roots().should.equal @digraph.roots()

    it "recreates selection after reset", ->
      memoized = @digraph.roots()
      @digraph.reset [ id: 1 ]
      @digraph.roots().should.not.equal memoized   

  describe "leaves()", ->
    
    it "is empty when not applicable", ->
      @digraph.leaves().should.be.an "array"
      @digraph.leaves().should.have.length 0
 
    
    it "returns nodes that have multiple parents", ->
      @digraph.reset [
          { id: 1, children: null }
          { id: 2, children: [1] }
          { id: 3, children: [4, 1] }     
          { id: 4, children: [] }
          { id: 5, children: [2, 3, 4] }
      ]
      ( leaf.id for leaf in @digraph.leaves() ).should.eql [1, 4]

    it "memoizes selection", ->
      @digraph.leaves().should.equal @digraph.leaves()


    it "recreates selection after update", ->
      memoized = @digraph.leaves()
      @digraph.reset [ id: 1 ]
      @digraph.leaves().should.not.equal memoized

  describe "junctions()", ->
    
    it "is empty when not applicable", ->
      @digraph.junctions().should.be.an "array"
      @digraph.junctions().should.have.length 0
 
    
    it "returns nodes that have multiple parents", ->
      @digraph.reset [
          { id: 1, children: null }
          { id: 2, children: [1] }
          { id: 3, children: [4, 1] }     
          { id: 4, children: [] }
          { id: 5, children: [2, 3, 4] }
      ]
      @digraph.junctions().should.have.length 2

    it "memoizes selection", ->
      @digraph.junctions().should.equal @digraph.junctions()


    it "recreates selection after update", ->
      memoized = @digraph.junctions()
      @digraph.reset [ id: 1 ]
      @digraph.junctions().should.not.equal memoized
