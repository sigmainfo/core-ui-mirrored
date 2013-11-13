#= require spec_helper
#= require views/widgets/concept_map/left_to_right

describe 'Coreon.Views.Widgets.ConceptMap.LeftToRight', ->

  beforeEach ->
    @svg = $ '<svg:g class="map">'
    @parent = d3.select @svg[0]
    @strategy = new Coreon.Views.Widgets.ConceptMap.LeftToRight @parent

  describe '#constructor()', ->

    it 'calls super', ->
      sinon.spy Coreon.Views.Widgets.ConceptMap.RenderStrategy::, 'constructor'
      try
        @strategy = new Coreon.Views.Widgets.ConceptMap.LeftToRight @parent
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.should.have.been.calledOnce
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.should.have.been.calledOn @strategy
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.should.have.been.calledWith @parent
      finally
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::constructor.restore()

    it 'sets node size of layout', ->
      nodeSize = @strategy.layout.nodeSize()
      should.exist nodeSize
      nodeSize[0].should.be.lt nodeSize[1]

    it 'changes projection of diagonal stencil', ->
      @strategy.diagonal.projection()(x: 5, y: 8).should.eql [8, 5]

  describe '#updateNodes()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers.Text, 'shorten'
      @selection = @parent.append('g').attr('class', 'concept-node')

    afterEach ->
      Coreon.Helpers.Text.shorten.restore()

    it 'calls super', ->
      sinon.spy Coreon.Views.Widgets.ConceptMap.RenderStrategy::, 'updateNodes'
      try
        nodes = @selection.data []
        @strategy.updateNodes nodes
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateNodes.should.have.been.calledOnce
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateNodes.should.have.been.calledOn @strategy
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateNodes.should.have.been.calledWith nodes
      finally
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateNodes.restore()

    it 'updates node position', ->
      nodes = @selection.data [
        x: '45'
        y: '123'
      ]
      @strategy.updateNodes nodes
      nodes.attr('transform').should.equal 'translate(123, 45)'

    it 'updates label', ->
      Coreon.Helpers.Text.shorten.withArgs('node 1234567890').returns 'node 123…'
      label = @selection.append('text').attr('class', 'label')
      nodes = @selection.data [
        label: 'node 1234567890'
      ]
      @strategy.updateNodes nodes
      label.text().should.equal 'node 123…'

    it 'positions label', ->
      label = @selection.append('text').attr('class', 'label')
      nodes = @selection.data [ label: 'node' ]
      @strategy.updateNodes nodes
      label.attr('x').should.equal '7'
      label.attr('y').should.equal '0.35em'
      label.attr('text-anchor').should.equal 'start'

    it 'positions background', ->
      background = @selection.append('rect').attr('class', 'background')
      nodes = @selection.data [ label: 'node' ]
      @strategy.updateNodes nodes
      background.attr('x').should.equal '-7'
      background.attr('y').should.equal '-8.5'

    it 'updates background dimensions', ->
      background = @selection.append('rect').attr('class', 'background')
      nodes = @selection.data [
        label: 'node'
        labelWidth: 200
      ]
      @strategy.updateNodes nodes
      background.attr('width').should.equal '200'
      background.attr('height').should.equal '17'

    context 'hits', ->

      it 'updates background position and height', ->
        background = @selection.append('rect').attr('class', 'background')
        nodes = @selection.data [ hit: yes ]
        @strategy.updateNodes nodes
        background.attr('height').should.equal '20'
        background.attr('y').should.equal '-11'

  describe '#updateEdges()', ->

    beforeEach ->
      @strategy.diagonal = sinon.stub()
      @selection = @parent.append('path').attr('class', 'concept-edge')

    it 'updates path between concepts', ->
      edges = @selection.data [
        source:
          id: 'source'
          type: 'concept'
          x: 123
          y: 45
          labelWidth: 123
        target:
          id: 'target'
          type: 'concept'
          x: 123
          y: 67
      ]
      @strategy.diagonal.withArgs(
        source:
          x: 123
          y: 45 + 123 - 7
        target:
          x: 123
          y: 67 - 7
      ).returns  'M179,123C119.5,123 119.5,123 60,123'
      @strategy.updateEdges edges
      edges.attr('d').should.equal 'M179,123C119.5,123 119.5,123 60,123'

    it 'updates path to idle placeholder', ->
      edges = @selection.data [
        source:
          id: 'source'
          type: 'concept'
          x: 123
          y: 45
          labelWidth: 123
        target:
          id: 'target'
          type: 'placeholder'
          busy: no
          x: 123
          y: 67
      ]
      @strategy.diagonal.withArgs(
        source:
          x: 123
          y: 45 + 123 - 7
        target:
          x: 123
          y: 67 - 7
      ).returns  'M179,123C119.5,123 119.5,123 60,113'
      @strategy.updateEdges edges
      edges.attr('d').should.equal 'M179,123C119.5,123 119.5,123 60,113'

    it 'updates path to loading placeholder', ->
      edges = @selection.data [
        source:
          id: 'source'
          type: 'concept'
          x: 123
          y: 45
          labelWidth: 123
        target:
          id: 'target'
          type: 'placeholder'
          busy: yes
          x: 123
          y: 67
      ]
      @strategy.diagonal.withArgs(
        source:
          x: 123
          y: 45 + 123 - 7
        target:
          x: 123
          y: 67 - 10
      ).returns  'M179,123C119.5,123 119.5,123 60,110'
      @strategy.updateEdges edges
      edges.attr('d').should.equal 'M179,123C119.5,123 119.5,123 60,110'

    it 'hides path when label width is unknown', ->
      edges = @selection.data [
        source:
          id: 'source'
          x: 123
          y: 45
          labelWidth: undefined
        target:
          id: 'target'
          x: 123
          y: 67
      ]
      @strategy.updateEdges edges
      edges.attr('d').should.equal 'm 0,0'

  describe '#updateLayout()', ->

    beforeEach ->
      @deferred = $.Deferred()
      @selection = @parent.append('g').attr('class', 'concept-node')
      @label = @selection.append('text').attr('class', 'label')
      @label.node().getBBox = -> width: 100
      @strategy.updateEdges = sinon.spy()

    it 'resizes background', ->
      background = @selection.append('rect').attr('class', 'background')
      nodes = @selection.data [ label: 'node 12345' ]
      @label.node().getBBox = -> width: 200
      @strategy.updateLayout nodes, [], @deferred
      background.attr('width').should.equal '225'

    it 'updates edges', ->
      nodes = @selection.data []
      edges = []
      @strategy.renderEdges = -> edges
      @strategy.updateLayout nodes, edges, @deferred
      @strategy.updateEdges.should.have.been.calledOnce
      @strategy.updateEdges.should.have.been.calledWith edges

    it 'calls super', ->
      nodes = @selection.data []
      edges = []
      sinon.spy Coreon.Views.Widgets.ConceptMap.RenderStrategy::, 'updateLayout'
      try
        updateOfSuper = Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateLayout
        returnValue = @strategy.updateLayout nodes, edges, @deferred
        expect( updateOfSuper ).to.have.been.calledOnce
        expect( updateOfSuper ).to.have.been.calledWith nodes, edges, @deferred
        expect( returnValue ).to.equal @deferred
      finally
        Coreon.Views.Widgets.ConceptMap.RenderStrategy::updateLayout.restore()

  describe '#center()', ->

    context 'without selection', ->

      it 'centers box horizontally', ->
        viewport =
          width:  300
          height: 200
        offset = @strategy.center viewport, null
        expect( offset.y ).to.equal 200 / 2

      it 'aligns lefts of map and viewport', ->
        viewport =
          width:  300
          height: 200
        offset = @strategy.center viewport, null
        expect( offset.x ).to.equal 300 * 0.1

    context 'with selection', ->

      it 'centers box inside viewport', ->
        viewport =
          width:  300
          height: 200
        box =
          x     : 12
          y     : 34
          width : 190
          height: 46
        offset = @strategy.center viewport, box
        expect( offset ).to.have.property 'x', (300 - 190) / 2 - 12
        expect( offset ).to.have.property 'y', (200 - 46 ) / 2 - 34
