#= require spec_helper
#= require modules/digraph

describe "Coreon.Modules.Digraph", ->

  before ->
    class Coreon.Models.MyNode extends Backbone.Model
      idAttribute: "id"

    class Coreon.Collections.MyGraph extends Backbone.Collection
      Coreon.Modules.include @, Coreon.Modules.Digraph

      model: Coreon.Models.MyNode

      initialize: ->
        @initializeDigraph()

  after ->
    delete Coreon.Models.MyNode
    delete Coreon.Collections.MyGraph
  
  beforeEach ->
    @graph = new Coreon.Collections.MyGraph []

  describe "tree()", ->

    context "creating datum nodes", ->
      
      it "creates root node", ->
        datum = @graph.tree()
        datum.should.have.property "id", "root"
        datum.should.have.property "children"
        datum.children.should.be.an "array"
        datum.children.should.be.empty

      it "creates datum from model", ->
        model = new Coreon.Models.MyNode id: "node"
        @graph.reset [ model ], silent: true
        tree = @graph.tree()
        tree.children.should.have.length 1
        datum = tree.children[0]
        datum.should.have.property "id", "node"
        datum.should.have.property "model", model
        datum.should.have.property "children"      
        datum.children.should.be.an "array"
        datum.children.should.be.empty
      
    context "connecting data", ->

      it "references child data", ->
        node  = new Coreon.Models.MyNode id: "node", childIds: [ "child" ]
        child = new Coreon.Models.MyNode id: "child"
        @graph.reset [ node, child ], silent: true
        tree = @graph.tree()
        datum = tree.children[0].children[0]
        datum.should.have.property "id", "child"
        datum.should.have.property "model", child

      it "takes options for graph walking", ->
        @graph.options.down = (model) -> model.get "subNodes" 
        node  = new Coreon.Models.MyNode id: "node", subNodes: [ "child" ]
        child = new Coreon.Models.MyNode id: "child"
        @graph.reset [ node, child ], silent: true
        tree = @graph.tree()
        datum = tree.children[0].children[0]
        datum.should.have.property "id", "child"
        datum.should.have.property "model", child

      it "ignore children that are not in collection", ->
        node  = new Coreon.Models.MyNode id: "node", childIds: [ "other" ]
        @graph.reset [ node ], silent: true
        tree = @graph.tree()
        tree.children[0].children.should.be.empty

      it "uses longest path for multiparented nodes", ->
        node  = new Coreon.Models.MyNode id: "node",  childIds: [ "child", "child_of_child" ]
        child = new Coreon.Models.MyNode id: "child", childIds: [ "child_of_child" ]
        childOfChild = new Coreon.Models.MyNode id: "child_of_child"
        @graph.reset [ node, child, childOfChild ], silent: true
        tree = @graph.tree()
        upper = tree.children[0]
        upper.children.should.have.length 1
        lower = upper.children[0]
        lower.should.have.property "id", "child"
        lower.children.should.have.length 1
        lower.children[0].should.have.property "id", "child_of_child"

