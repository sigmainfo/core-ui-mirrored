#= require spec_helper
#= require views/widgets/concept_map/left_to_right

describe "Coreon.Views.Widgets.ConceptMap.LeftToRight", ->

  beforeEach ->
    @svg = $ "<svg:g class='map'>"
    @strategy = new Coreon.Views.Widgets.ConceptMap.LeftToRight d3.select @svg.get 0

  describe "initialize()", ->

    it "works on passed in selection", ->
      map = d3.select $("<svg:g>").get 0
      @strategy.initialize map
      @strategy.selection.should.equal map

    it "creates layout", ->
      layout = {}
      sinon.stub(d3.layout, "tree").returns layout
      try
        @strategy.initialize @svg
        @strategy.layout.should.equal layout
      finally
        d3.layout.tree.restore()

    it "creates diagonals factory", ->
      diagonal = d3.svg.diagonal()
      sinon.stub d3.svg, "diagonal", -> diagonal
      try
        @strategy.initialize @svg
        @strategy.stencil.should.equal diagonal
        @strategy.stencil.projection()(x: "x", y: "y").should.eql ["y", "x"]
      finally
        d3.svg.diagonal.restore()

  describe "render()", ->
    before ->
      Coreon.Helpers.repositoryPath = (s)-> "/coffee23/"+s


    context "nodes", ->

      it "does not render root node", ->
        @strategy.render
          root:
            children: []
          edges: []
        @svg.should.not.have ".concept-node"

      context "updating node instances", ->

        it "renders additional nodes", ->
          @strategy.render
            root:
              children: [
                { id: "node_1", model: new Backbone.Model(id: "node_1", label: "Node 1", concept: new Backbone.Model(_id: "node_1")) } #TODO: reduce dependencies
                { id: "node_2", model: new Backbone.Model(id: "node_2", label: "Node 2", concept: new Backbone.Model(_id: "node_2")) }
              ]
            edges: []
          @svg.find(".concept-node").should.have.lengthOf 2

        it "removes deprecated nodes", ->
          @strategy.render
            root:
              children: [
                { id: "node_1", model: new Backbone.Model(id: "node_1", label: "Node 1", concept: new Backbone.Model(_id: "node_1")) }
              ]
            edges: []
          @strategy.render
            root:
              children: []
            edges: []
          @svg.should.not.have ".concept-node"

      context "updating positions", ->

        beforeEach ->
          @data =
            root: children: []
            edges: []

        it "applies render size", ->
          @strategy.options.padding = 25
          @strategy.size = [0, 0]
          @strategy.layout.size = sinon.stub().returns @strategy.layout
          @strategy.render @data, size: [300, 200]
          @strategy.size.should.eql [250, 150]
          @strategy.layout.size.should.have.been.calledOnce
          @strategy.layout.size.should.have.been.calledWith [150, 250]


        it "passes tree to layout", ->
          @strategy.layout.nodes = sinon.stub().returns [ id: "root" ]
          @strategy.render @data
          @strategy.layout.nodes.should.have.been.calledOnce
          @strategy.layout.nodes.should.have.been.calledWith @data.root

        it "updates node coordinates", ->
          @strategy.options.padding = 25
          @strategy.options.offsetX = 100
          @strategy.layout.nodes = ->
            [
              { id: "root" }
              {
                id: "node_1"
                model: new Backbone.Model(id: "node_1", label: "Node 1", concept: new Backbone.Model(_id: "node_1"))
                depth: 3
                x: 27
                y: 380
              }
              {
                id: "node_2"
                model: new Backbone.Model(id: "node_2", label: "Node 2", concept: new Backbone.Model(_id: "node_2"))
                depth: 5
                x: 154
                y: 560
              }
            ]
          @strategy.render @data
          datum1 = d3.select( @svg.find(".concept-node").get(0) ).data()[0]
          datum1.should.have.property "x", 225
          datum1.should.have.property "y", 52

          datum2 = d3.select( @svg.find(".concept-node").get(1) ).data()[0]
          datum2.should.have.property "x", 425
          datum2.should.have.property "y", 179

        it "preserves minimal y offset", ->
          node_1 =
            id: "node_1"
            model: new Backbone.Model(id: "node_1", label: "Node 1", concept: new Backbone.Model(_id: "node_1"))
            depth: 3
            x: 0
            y: 0
          node_2 =
            id: "node_2"
            model: new Backbone.Model(id: "node_2", label: "Node 2", concept: new Backbone.Model(_id: "node_2"))
            depth: 3
            x: 15
            y: 0
          root =
            id: "root"
            children: [node_1, node_2]
          @strategy.layout.nodes = -> [ root, node_1, node_2 ]
          @strategy.options.padding = 5
          @strategy.options.offsetY = 30
          @strategy.render @data
          datum1 = d3.select( @svg.find(".concept-node").get(0) ).data()[0]
          datum1.should.have.property "y", 5

          datum2 = d3.select( @svg.find(".concept-node").get(1) ).data()[0]
          datum2.should.have.property "y", 35

        it "moves views to new position", ->
          @strategy.options.padding = 25
          @strategy.options.offsetX = 100
          @strategy.layout.nodes = ->
            [
              { id: "root" }
              {
                id: "node_1"
                model: new Backbone.Model(id: "node_1", label: "Node 1", concept: new Backbone.Model(_id: "node_1"))
                depth: 3
                x: 27
              }
            ]
          @strategy.render @data
          @svg.find(".concept-node").should.have.attr "transform", "translate(225, 52)"

      context "updating view instances", ->

        beforeEach ->
          @node = new Backbone.Model _id: "node", label: "Node", concept: new Backbone.Model(_id: "node")
          @node.cid = "c123"

        it "creates view for newly created node", ->
          @strategy.render
            root:
              children: [
                id: "node"
                model: @node
              ]
            edges: []
          @strategy.views.should.have.property("c123").that.is.an.instanceof Coreon.Views.Concepts.ConceptNodeView
          @strategy.views.should.have.deep.property "c123.el", @svg.find(".concept-node").get(0)
          @strategy.views.should.have.deep.property "c123.model", @node

        it "resolves view for removed views", ->
          @strategy.render
            root:
              children: [
                id: "node"
                model: @node
              ]
            edges: []
          spy = sinon.spy()
          @strategy.views["c123"].stopListening = spy
          @strategy.render
            root:
              children: []
            edges: []
          spy.should.have.been.calledOnce
          should.not.exist @strategy.views["c123"]

    context "edges", ->

      beforeEach ->
        @strategy.views =
          c_parent:  box: -> height: 0, width: 0
          c_child_1: box: -> height: 0, width: 0
          c_child_2: box: -> height: 0, width: 0

      it "renders newly added eges", ->
        @strategy.render
          root: children: []
          edges: [
            {
              source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent", has: -> false } }
              target: { id: "child_1", x: 0, y: 0, model: { cid: "c_child_1", has: -> false } }
            }
            {
              source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent", has: -> false } }
              target: { id: "child_2", x: 0, y: 0, model: { cid: "c_child_2", has: -> false } }
            }
          ]
        @svg.should.have ".concept-edge"
        @svg.find(".concept-edge").size().should.equal 2

      it "removes dropped edges", ->
        @strategy.render
          root: children: []
          edges: [
            {
              source: { id: "parent",  x: 0, y: 0, model: { cid: "c_parent", has: -> false } }
              target: { id: "child_1", x: 0, y: 0, model: { cid: "c_child_1", has: -> false } }
            }
          ]
        @strategy.render
          root: children: []
          edges: []
        @svg.should.not.have ".concept-edge"

      it "renders curves from box to box", ->
        @strategy.views =
          c_parent:  box: -> height: 30, width: 120
          c_child_1: box: -> height: 20, width: 150
        @strategy.render
          root: children: []
          edges: [
            source: { id: "parent",  x: 20, y: 25, model: { cid: "c_parent", has: -> false } }
            target: { id: "child_1", x: 40, y: 55, model: { cid: "c_child_1", has: -> false } }
          ]
        @svg.find(".concept-edge").should.have.attr("d").with.match /M140,40.*40,70/

