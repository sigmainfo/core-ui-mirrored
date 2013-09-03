#= require spec_helper
#= require views/widgets/concept_map/left_to_right
#= require views/widgets/concept_map/concept_node_list_view

describe "Coreon.Views.Widgets.ConceptMap.LeftToRight", ->

  beforeEach ->
    @svg = $ "<svg:g class='map'>"
    @selection = d3.select @svg[0]
    @strategy = new Coreon.Views.Widgets.ConceptMap.LeftToRight @selection

  describe "constructor()", ->

    it "stores reference to selection", ->
      @strategy.selection.should.equal @selection

    it "creates diagonal factory and layout", ->
      @strategy.should.have.property "layout"
      @strategy.should.have.property "diagonal"

    it "changes projection of diagonal stencil", ->
      @strategy.diagonal.projection()(x: 5, y: 8).should.eql [8, 5]

  describe "renderNodes()", ->

    beforeEach ->
      sinon.stub Coreon.Helpers, "repositoryPath", (path) ->
        "/my-repo/#{path}"

    afterEach ->
      Coreon.Helpers.repositoryPath.restore()

    it "skips rendering of root node", ->
      @strategy.renderNodes children: []
      @svg.should.not.have "g.concept-node"

    it "creates new nodes", ->
      @strategy.renderNodes children: [
        { children: [] }
        { children: [ children: [] ] }
      ]
      @svg.find("g.concept-node").should.have.lengthOf 3
  
    it "removes deprecated nodes", ->
      @strategy.renderNodes children = [
        { children: [] }
        { children: [ children: [] ] }
      ]
      @strategy.renderNodes children: [ children: [] ]
      @svg.find("g.concept-node").should.have.lengthOf 1

    it "updates position of nodes", ->
      @strategy.layout.nodeSize [25, 100]
      @strategy.renderNodes children: [ children: [] ]
      @strategy.renderNodes children: [
        { children: [] }
        { children: [] }
      ]
      concept = d3.select @svg.find(".concept-node")[0]
      datum = concept.datum()
      datum.should.have.property "x", -12.5
      datum.should.have.property "y", 100
      concept.should.have.attr "transform", "translate(100, -12.5)"

    it "renders link to concept", ->
      @strategy.renderNodes children: [ id: "345" ]
      link = d3.select @svg.find(".concept-node a")[0]
      should.exist link.node()
      link.should.have.attr "xlink:href", "/my-repo/concepts/345"

    it "renders dummy link for new concept", ->
      @strategy.renderNodes children: [ children: [] ]
      link = d3.select @svg.find(".concept-node a")[0]
      should.exist link.node()
      link.should.have.attr "xlink:href", "javascript:void(0)"

    it "renders label text", ->
      @strategy.renderNodes children: [ label: "revolver" ]
      label = d3.select @svg.find(".concept-node a text")[0]
      should.exist label.node()
      label.should.have.text "revolver"

    it "shortens lengthy labels", ->
      sinon.stub Coreon.Helpers.Text, "shorten"
      try
        Coreon.Helpers.Text.shorten.withArgs("this is a little bit verbose").returns "this is …"
        @strategy.renderNodes children: [ label: "this is a little bit verbose" ]
        label = d3.select @svg.find(".concept-node a text")[0]
        should.exist label.node()
        label.should.have.text "this is …"
      finally
        Coreon.Helpers.Text.shorten.restore()

    it "renders background for labels", ->
      @strategy.renderNodes children: [ children: [] ]
      bg = d3.select @svg.find(".concept-node a use")[0]
      should.exist bg.node()
      bg.should.have.attr "xlink:href", "#coreon-node-label-background"
      

#       context "updating positions", ->
# 
#         beforeEach ->
#           @data =
#             root: children: []
#             edges: []
# 
#         it "updates node coordinates", ->
#           @strategy.options.padding = 25
#           @strategy.options.offsetX = 100
#           @strategy.layout.nodes = ->
#             [
#               { id: "root" }
#               {
#                 id: "node_1"
#                 model: new Backbone.Model(id: "node_1", label: "Node 1", concept: new Backbone.Model(_id: "node_1"))
#                 depth: 3
#                 x: 27
#                 y: 380
#               }
#               {
#                 id: "node_2"
#                 model: new Backbone.Model(id: "node_2", label: "Node 2", concept: new Backbone.Model(_id: "node_2"))
#                 depth: 5
#                 x: 154
#                 y: 560
#               }
#             ]
#           @strategy.render @data
#           datum1 = d3.select( @svg.find(".concept-node").get(0) ).data()[0]
#           datum1.should.have.property "x", 225
#           datum1.should.have.property "y", 52
# 
#           datum2 = d3.select( @svg.find(".concept-node").get(1) ).data()[0]
#           datum2.should.have.property "x", 425
#           datum2.should.have.property "y", 179
# 
#         it "preserves minimal y offset", ->
#           node_1 =
#             id: "node_1"
#             model: new Backbone.Model(id: "node_1", label: "Node 1", concept: new Backbone.Model(_id: "node_1"))
#             depth: 3
#             x: 0
#             y: 0
#           node_2 =
#             id: "node_2"
#             model: new Backbone.Model(id: "node_2", label: "Node 2", concept: new Backbone.Model(_id: "node_2"))
#             depth: 3
#             x: 15
#             y: 0
#           root =
#             id: "root"
#             children: [node_1, node_2]
#           @strategy.layout.nodes = -> [ root, node_1, node_2 ]
#           @strategy.options.padding = 5
#           @strategy.options.offsetY = 30
#           @strategy.render @data
#           datum1 = d3.select( @svg.find(".concept-node").get(0) ).data()[0]
#           datum1.should.have.property "y", 5
# 
#           datum2 = d3.select( @svg.find(".concept-node").get(1) ).data()[0]
#           datum2.should.have.property "y", 35
# 
#         it "moves views to new position", ->
#           @strategy.options.padding = 25
#           @strategy.options.offsetX = 100
#           @strategy.layout.nodes = ->
#             [
#               { id: "root" }
#               {
#                 id: "node_1"
#                 model: new Backbone.Model(id: "node_1", label: "Node 1", concept: new Backbone.Model(_id: "node_1"))
#                 depth: 3
#                 x: 27
#               }
#             ]
#           @strategy.render @data
#           @svg.find(".concept-node").should.have.attr "transform", "translate(225, 52)"
# 
#       context "updating view instances", ->
# 
#         beforeEach ->
#           @node = new Backbone.Model _id: "node", label: "Node", concept: new Backbone.Model(_id: "node")
#           @node.cid = "c123"
# 
#         it "creates view for newly created node", ->
#           @strategy.render
#             root:
#               children: [
#                 id: "node"
#                 model: @node
#               ]
#             edges: []
#           @strategy.views.should.have.property("c123").that.is.an.instanceof Coreon.Views.Widgets.ConceptMap.ConceptNodeListView
#           @strategy.views.should.have.deep.property "c123.el", @svg.find(".concept-node").get(0)
#           @strategy.views.should.have.deep.property "c123.model", @node
# 
#         it "resolves view for removed views", ->
#           @strategy.render
#             root:
#               children: [
#                 id: "node"
#                 model: @node
#               ]
#             edges: []
#           spy = sinon.spy()
#           @strategy.views["c123"].stopListening = spy
#           @strategy.render
#             root:
#               children: []
#             edges: []
#           spy.should.have.been.calledOnce
#           should.not.exist @strategy.views["c123"]
# 
#     context "edges", ->
# 
#       beforeEach ->
#         @strategy.views =
#           c_parent:  box: -> height: 0, width: 0
#           c_child_1: box: -> height: 0, width: 0
#           c_child_2: box: -> height: 0, width: 0
# 
#       it "renders newly added eges", ->
#         @strategy.render
#           root: children: []
#           edges: [
#             {
#               source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent", has: -> false } }
#               target: { id: "child_1", x: 0, y: 0, model: { cid: "c_child_1", has: -> false } }
#             }
#             {
#               source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent", has: -> false } }
#               target: { id: "child_2", x: 0, y: 0, model: { cid: "c_child_2", has: -> false } }
#             }
#           ]
#         @svg.should.have ".concept-edge"
#         @svg.find(".concept-edge").size().should.equal 2
# 
#       it "removes dropped edges", ->
#         @strategy.render
#           root: children: []
#           edges: [
#             {
#               source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent", has: -> false } }
#               target: { id: "child_1", x: 0, y: 0, model: { cid: "c_child_1", has: -> false } }
#             }
#           ]
#         @strategy.render
#           root: children: []
#           edges: []
#         @svg.should.not.have ".concept-edge"
# 
#       it "renders curves from box to box", ->
#         @strategy.views =
#           c_parent:  box: -> height: 30, width: 120
#           c_child_1: box: -> height: 20, width: 150
#         @strategy.render
#           root: children: []
#           edges: [
#             source: { id: "parent",  x: 20, y: 25, model: { cid: "c_parent", has: -> false } }
#             target: { id: "child_1", x: 40, y: 55, model: { cid: "c_child_1", has: -> false } }
#           ]
#         @svg.find(".concept-edge").should.have.attr("d").with.match /M140,40.*40,70/
# 
