#= require spec_helper
#= require views/widgets/concept_map/top_down

describe "Coreon.Views.Widgets.ConceptMap.TopDown", ->

  beforeEach ->
    sinon.stub _, "defer"
    @svg = $ "<svg:g class='map'>"
    @parent = d3.select @svg[0]
    @strategy = new Coreon.Views.Widgets.ConceptMap.TopDown @parent

  afterEach ->
    _.defer.restore()

  describe "constructor()", ->

    it "calls super", ->
      sinon.spy Coreon.Views.Widgets.ConceptMap.RenderStrategy::, "constructor"
      try
        @strategy = new Coreon.Views.Widgets.ConceptMap.TopDown @parent
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.should.have.been.calledOnce
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.should.have.been.calledOn @strategy
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.should.have.been.calledWith @parent 
      finally
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.restore()

    it "sets node size of layout", ->
      nodeSize = @strategy.layout.nodeSize()
      should.exist nodeSize
      nodeSize[1].should.be.lt nodeSize[0]

  describe "updateNodes()", ->

    beforeEach ->
      sinon.stub Coreon.Helpers.Text, "wrap"
      @selection = @parent.append("g").attr("class", "concept-node")

    afterEach ->
      Coreon.Helpers.Text.wrap.restore()

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
      nodes.attr("transform").should.equal "translate(45, 123)" 
    
    it "updates label", ->
      Coreon.Helpers.Text.wrap.withArgs("lorem ipsum dolor sic amet")
        .returns ["lorem ipsum dolor", "sic amet"]
      label = @selection.append("text").attr("class", "label")
      nodes = @selection.data [
        label: "lorem ipsum dolor sic amet"
      ]
      @strategy.updateNodes nodes
      label.html().should.equal '<tspan x="0">lorem ipsum dolor</tspan><tspan x="0" dy="15">sic amet</tspan>'

    it "positions label", ->
      Coreon.Helpers.Text.wrap.withArgs("node").returns [ "node" ]
      label = @selection.append("text").attr("class", "label")
      nodes = @selection.data [ label: "node" ]
      @strategy.updateNodes nodes
      label.attr("x").should.equal "0"
      label.attr("y").should.equal "20"
      label.attr("text-anchor").should.equal "middle"

    it "positions background", ->
      background = @selection.append("rect").attr("class", "background")
      nodes = @selection.data [ label: "node" ]
      @strategy.updateNodes nodes
      background.attr("y").should.equal "7"

    it "updates background dimensions", ->
      Coreon.Helpers.Text.wrap.withArgs("lorem ipsum dolor sic amet")
        .returns ["lorem ipsum dolor", "sic amet"]
      label = @selection.append("text").attr("class", "label")
      background = @selection.append("rect").attr("class", "background")
      nodes = @selection.data [
        label: "lorem ipsum dolor sic amet"
      ]
      @strategy.updateNodes nodes
      nodes.datum().should.have.property "labelHeight", 33
      background.attr("height").should.equal "33"

      it "updates background position and height", ->
        Coreon.Helpers.Text.wrap.withArgs("lorem ipsum dolor sic amet")
          .returns ["lorem ipsum dolor", "sic amet"]
        label = @selection.append("text").attr("class", "label")
        background = @selection.append("rect").attr("class", "background")
        nodes = @selection.data [
          hit: yes
          label: "lorem ipsum dolor sic amet"
        ]
        @strategy.updateNodes nodes
        background.attr("height").should.equal "38"
        background.attr("y").should.equal "6"

  describe "updateEdges()", ->
    
    beforeEach ->
      @strategy.diagonal = sinon.stub()
      @selection = @parent.append("path").attr("class", "concept-edge")

    it "updates path between concepts", ->
      edges = @selection.data [
        source:
          id: "source"
          type: "concept"
          x: 123
          y: 45
          labelHeight: 50
        target:
          id: "target"
          type: "concept"
          x: 123
          y: 67
      ]
      @strategy.diagonal.withArgs(
        source:
          x: 123
          y: 45 + 50 + 7
        target:
          x: 123
          y: 67 - 3.5
      ).returns  "M179,123C119.5,123 119.5,123 60,123"
      @strategy.updateEdges edges
      edges.attr("d").should.equal "M179,123C119.5,123 119.5,123 60,123"

    it "updates path to placeholder", ->
      edges = @selection.data [
        source:
          id: "source"
          type: "concept"
          x: 123
          y: 45
          labelHeight: 50
        target:
          id: "target"
          type: "placeholder"
          x: 123
          y: 67
      ]
      @strategy.diagonal.withArgs(
        source:
          x: 123
          y: 45 + 50 + 7
        target:
          x: 123
          y: 67 - 10
      ).returns  "M179,123C119.5,123 119.5,123 60,113"
      @strategy.updateEdges edges
      edges.attr("d").should.equal "M179,123C119.5,123 119.5,123 60,113"

  describe "updateLayout()", ->

    beforeEach ->
      @selection = @parent.append("g").attr("class", "concept-node")
      @nodes = @selection.data [ label: "node 12345" ]
      @edges = @selection.data []
  
    it "resizes and repositions background", ->
      label = @selection.append("text").attr("class", "label")
      label.node().getBBox = -> width: 100
      background = @selection.append("rect").attr("class", "background")
      @strategy.updateLayout @nodes, @edges
      background.attr("width").should.equal "116"
      background.attr("x").should.equal "-58"

    it "updates edges", ->
      @strategy.updateEdges = sinon.spy()
      @strategy.updateLayout @nodes, @edges
      @strategy.updateEdges.should.have.been.calledOnce
      @strategy.updateEdges.should.have.been.calledWith @edges
