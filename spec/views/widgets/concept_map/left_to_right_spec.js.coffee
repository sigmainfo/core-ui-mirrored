#= require spec_helper
#= require views/widgets/concept_map/left_to_right

describe "Coreon.Views.Widgets.ConceptMap.LeftToRight", ->

  beforeEach ->
    @svg = $ "<svg:g class='map'>"
    @parent = d3.select @svg[0]
    @strategy = new Coreon.Views.Widgets.ConceptMap.LeftToRight @parent

  describe "constructor()", ->

    it "calls super", ->
      sinon.spy Coreon.Views.Widgets.ConceptMap.RenderStrategy::, "constructor"
      try
        @strategy = new Coreon.Views.Widgets.ConceptMap.LeftToRight @parent
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.should.have.been.calledOnce
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.should.have.been.calledOn @strategy
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.should.have.been.calledWith @parent 
      finally
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.restore()

    it "sets node size of layout", ->
      nodeSize = @strategy.layout.nodeSize()
      should.exist nodeSize
      nodeSize[0].should.be.lt nodeSize[1]

    it "changes projection of diagonal stencil", ->
      @strategy.diagonal.projection()(x: 5, y: 8).should.eql [8, 5]

  describe "createNodes()", ->

    beforeEach ->
      @selection = @parent.selectAll(".concept-node")

    it "calls super", ->
      nodes = @selection.data []
      sinon.stub Coreon.Views.Widgets.ConceptMap.RenderStrategy::, "createNodes", -> nodes
      try
        @strategy.createNodes nodes.enter()
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::createNodes.should.have.been.calledOnce
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::createNodes.should.have.been.calledOn @strategy
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::createNodes.should.have.been.calledWith nodes.enter()
      finally
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::createNodes.restore()

    it "positions label", ->
      nodes = @selection.data [ label: "node 123" ]
      @strategy.createNodes nodes.enter()
      label = nodes.select("text.label")
      label.attr("dx").should.equal "7"
      label.attr("dy").should.equal "0.35em"

    it "positions background", ->
      nodes = @selection.data [ label: "node 123" ]
      @strategy.createNodes nodes.enter()
      background = nodes.select("rect.background")
      background.attr("x").should.equal "-7"

  describe "updateNodes()", ->

    beforeEach ->
      sinon.stub Coreon.Helpers.Text, "shorten"
      @selection = @parent.append("g").attr("class", "concept-node")

    afterEach ->
      Coreon.Helpers.Text.shorten.restore()

    it "calls super", ->
      sinon.spy Coreon.Views.Widgets.ConceptMap.RenderStrategy::, "updateNodes"
      try
        nodes = @selection.data []
        @strategy.updateNodes nodes
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateNodes.should.have.been.calledOnce
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateNodes.should.have.been.calledOn @strategy
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateNodes.should.have.been.calledWith nodes
      finally
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateNodes.restore()
    
    it "updates node position", ->
      nodes = @selection.data [
        x: "45"
        y: "123"
      ]
      @strategy.updateNodes nodes
      nodes.attr("transform").should.equal "translate(123, 45)" 

    it "updates label", ->
      Coreon.Helpers.Text.shorten.withArgs("node 1234567890").returns "node 123…"
      label = @selection.append("text").attr("class", "label")
      label.node().getBBox = -> width: 120
      nodes = @selection.data [
        label: "node 1234567890"
      ]
      @strategy.updateNodes nodes
      label.text().should.equal "node 123…"

    it "updates background width to fit label text", ->
      label = @selection.append("text").attr("class", "label")
      label.node().getBBox = -> width: 123
      background = @selection.append("rect").attr("class", "background")
      nodes = @selection.data [
        label: "node"
      ]
      @strategy.updateNodes nodes
      background.attr("width").should.equal "143"

    it "updates background position and height according to hit state", ->
      background = @selection.append("rect").attr("class", "background")
      nodes = @selection.data [ hit: no ]
      @strategy.updateNodes nodes
      background.attr("height").should.equal "17"
      background.attr("y").should.equal "-8.5"
      nodes = @selection.data [ hit: yes ]
      @strategy.updateNodes nodes
      background.attr("height").should.equal "20"
      background.attr("y").should.equal "-10"

    it "positions toggle for parents", ->
      toggle = @selection.append("g").attr("class", "toggle-parents")
      nodes = @selection.data [ root: no ]
      @strategy.updateNodes nodes
      toggle.attr("transform").should.include "translate(-15, 0)"

    it "rotates toggle for parents depending on expansion state", ->
      toggle = @selection.append("g").attr("class", "toggle-parents")
      nodes = @selection.data [
        root: no
        expandedIn: yes
      ]
      @strategy.updateNodes nodes
      toggle.attr("transform").should.include "rotate(90)"
      nodes = @selection.data [
        root: no
        expandedIn: no
      ]
      @strategy.updateNodes nodes
      toggle.attr("transform").should.include "rotate(0)"

    it "positions toggle for children", ->
      toggle = @selection.append("g").attr("class", "toggle-children")
      nodes = @selection.data [
        leaf: no
        textWidth: 120
      ]
      @strategy.updateNodes nodes
      toggle.attr("transform").should.include "translate(141, 0)"

    it "rotates toggle for children depending on expansion state", ->
      toggle = @selection.append("g").attr("class", "toggle-children")
      nodes = @selection.data [
        leaf: no
        expandedOut: yes
      ]
      @strategy.updateNodes nodes
      toggle.attr("transform").should.include "rotate(90)"
      nodes = @selection.data [
        leaf: no
        expandedOut: no
      ]
      @strategy.updateNodes nodes
      toggle.attr("transform").should.include "rotate(0)"
      

  describe "updateEdges()", ->
    
    beforeEach ->
      @strategy.diagonal = sinon.stub()
      @selection = @parent.append("path").attr("class", "concept-edge")

    it "updates path", ->
      edges = @selection.data [
        source:
          id: "source"
          x: 123
          y: 45
          textWidth: 120
        target:
          id: "target"
          x: 123
          y: 67
      ]
      @strategy.diagonal.withArgs(
        source:
          x: 123
          y: 45 + 120 +14
        target:
          x: 123
          y: 67 - 7
      ).returns  "M179,123C119.5,123 119.5,123 60,123"
      @strategy.updateEdges edges
      edges.attr("d").should.equal "M179,123C119.5,123 119.5,123 60,123"
      
    
