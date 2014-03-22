#= require spec_helper
#= require lib/concept_map/top_down

describe 'Coreon.Lib.ConceptMap.TopDown', ->

  beforeEach ->
    sinon.stub _, 'defer'
    @svg = $ '<svg:g class="map">'
    @parent = d3.select @svg[0]
    @strategy = new Coreon.Lib.ConceptMap.TopDown @parent

  afterEach ->
    _.defer.restore()

  describe '#constructor()', ->

    it 'calls super', ->
      sinon.spy Coreon.Lib.ConceptMap.RenderStrategy::, 'constructor'
      try
        @strategy = new Coreon.Lib.ConceptMap.TopDown @parent
        Coreon.Lib.ConceptMap.RenderStrategy::constructor.should.have.been.calledOnce
        Coreon.Lib.ConceptMap.RenderStrategy::constructor.should.have.been.calledOn @strategy
        Coreon.Lib.ConceptMap.RenderStrategy::constructor.should.have.been.calledWith @parent
      finally
        Coreon.Lib.ConceptMap.RenderStrategy::constructor.restore()

    it 'sets node size of layout', ->
      nodeSize = @strategy.layout.nodeSize()
      should.exist nodeSize
      nodeSize[1].should.be.lt nodeSize[0]

  describe '#updateNodes()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers.Text, 'wrap'
      @selection = @parent.append('g').attr('class', 'concept-node')

    afterEach ->
      Coreon.Helpers.Text.wrap.restore()

    it 'calls super', ->
      sinon.spy Coreon.Lib.ConceptMap.RenderStrategy::, 'updateNodes'
      try
        nodes = @selection.data []
        @strategy.updateNodes nodes
        Coreon.Lib.ConceptMap.RenderStrategy::updateNodes.should.have.been.calledOnce
        Coreon.Lib.ConceptMap.RenderStrategy::updateNodes.should.have.been.calledOn @strategy
        Coreon.Lib.ConceptMap.RenderStrategy::updateNodes.should.have.been.calledWith nodes
      finally
        Coreon.Lib.ConceptMap.RenderStrategy::updateNodes.restore()

    it 'moves nodes to new position', ->
      nodes = @selection.data [
        x: '45'
        y: '123'
      ]
      nodes.transition = -> nodes
      nodes.duration   = -> nodes
      nodes.ease       = -> nodes
      @strategy.updateNodes nodes
      nodes.attr('transform').should.equal 'translate(45, 123)'

    it 'updates label', ->
      Coreon.Helpers.Text.wrap.withArgs('lorem ipsum dolor sic amet')
        .returns ['lorem ipsum dolor', 'sic amet']
      label = @selection.append('text').attr('class', 'label')
      nodes = @selection.data [
        label: 'lorem ipsum dolor sic amet'
      ]
      @strategy.updateNodes nodes
      label.html().should.equal '<tspan x="0">lorem ipsum dolor</tspan><tspan x="0" dy="15">sic amet</tspan>'

    it 'positions label', ->
      Coreon.Helpers.Text.wrap.withArgs('node').returns [ 'node' ]
      label = @selection.append('text').attr('class', 'label')
      nodes = @selection.data [ label: 'node' ]
      @strategy.updateNodes nodes
      label.attr('x').should.equal '0'
      label.attr('y').should.equal '20'
      label.attr('text-anchor').should.equal 'middle'

    it 'positions background', ->
      background = @selection.append('rect').attr('class', 'background')
      nodes = @selection.data [ label: 'node' ]
      @strategy.updateNodes nodes
      background.attr('y').should.equal '7'

    it 'updates background dimensions', ->
      Coreon.Helpers.Text.wrap.withArgs('lorem ipsum dolor sic amet')
        .returns ['lorem ipsum dolor', 'sic amet']
      label = @selection.append('text').attr('class', 'label')
      background = @selection.append('rect').attr('class', 'background')
      nodes = @selection.data [
        label: 'lorem ipsum dolor sic amet'
      ]
      @strategy.updateNodes nodes
      nodes.datum().should.have.property 'labelHeight', 33
      background.attr('height').should.equal '33'

      it 'updates background position and height', ->
        Coreon.Helpers.Text.wrap.withArgs('lorem ipsum dolor sic amet')
          .returns ['lorem ipsum dolor', 'sic amet']
        label = @selection.append('text').attr('class', 'label')
        background = @selection.append('rect').attr('class', 'background')
        nodes = @selection.data [
          hit: yes
          label: 'lorem ipsum dolor sic amet'
        ]
        @strategy.updateNodes nodes
        background.attr('height').should.equal '38'
        background.attr('y').should.equal '6'

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
          labelHeight: 50
        target:
          id: 'target'
          type: 'concept'
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
      ).returns  'M179,123C119.5,123 119.5,123 60,123'
      edges.transition = -> edges
      edges.duration   = -> edges
      edges.ease       = -> edges
      @strategy.updateEdges edges
      edges.attr('d').should.equal 'M179,123C119.5,123 119.5,123 60,123'

    it 'updates path to idle placeholder', ->
      edges = @selection.data [
        source:
          id: 'source'
          type: 'concept'
          x: 123
          y: 45
          labelHeight: 50
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
          y: 45 + 50 + 7
        target:
          x: 123
          y: 67 - 7
      ).returns  'M179,123C119.5,123 119.5,123 60,110'
      edges.transition = -> edges
      edges.duration   = -> edges
      edges.ease       = -> edges
      @strategy.updateEdges edges
      edges.attr('d').should.equal 'M179,123C119.5,123 119.5,123 60,110'

    it 'updates path to loading placeholder', ->
      edges = @selection.data [
        source:
          id: 'source'
          type: 'concept'
          x: 123
          y: 45
          labelHeight: 50
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
          y: 45 + 50 + 7
        target:
          x: 123
          y: 67 - 10
      ).returns  'M179,123C119.5,123 119.5,123 60,113'
      edges.transition = -> edges
      edges.duration   = -> edges
      edges.ease       = -> edges
      @strategy.updateEdges edges
      edges.attr('d').should.equal 'M179,123C119.5,123 119.5,123 60,113'

  describe '#updateLayout()', ->

    beforeEach ->
      @deferred = $.Deferred()
      @selection = @parent.append('g').attr('class', 'concept-node')
      @nodes = @selection.data [ label: 'node 12345' ]
      @edges = @selection.data []

    it 'resizes and repositions background', ->
      label = @selection.append('text').attr('class', 'label')
      label.node().getBBox = -> width: 100
      background = @selection.append('rect').attr('class', 'background')
      @strategy.updateLayout @nodes, @edges, @deferred
      background.attr('width').should.equal '116'
      background.attr('x').should.equal '-58'

    it 'updates edges', ->
      @strategy.updateEdges = sinon.spy()
      @strategy.updateLayout @nodes, @edges, @deferred
      @strategy.updateEdges.should.have.been.calledOnce
      @strategy.updateEdges.should.have.been.calledWith @edges

    it 'calls super', ->
      sinon.spy Coreon.Lib.ConceptMap.RenderStrategy::, 'updateLayout'
      try
        updateOfSuper = Coreon.Lib.ConceptMap.RenderStrategy::updateLayout
        returnValue = @strategy.updateLayout @nodes, @edges, @deferred
        expect( updateOfSuper ).to.have.been.calledOnce
        expect( updateOfSuper ).to.have.been.calledWith @nodes, @edges, @deferred
        expect( returnValue ).to.equal @deferred
      finally
        Coreon.Lib.ConceptMap.RenderStrategy::updateLayout.restore()

  describe '#center()', ->

    beforeEach ->
      @data = []
      @nodes = data: => @data

    context 'without selection', ->

      beforeEach ->
        @data = []

      it 'centers root vertically', ->
        viewport =
          width:  300
          height: 200
        offset = @strategy.center viewport, @nodes
        expect( offset.x ).to.equal 150

      it 'aligns root with top', ->
        viewport =
          width:  300
          height: 200
        offset = @strategy.center viewport, @nodes
        expect( offset.y ).to.equal 0

    context 'with selection', ->

      beforeEach ->
        @data = [ x: 45, y: 789 ]

      it 'centers box inside viewport', ->
        viewport =
          width:  300
          height: 200
        @strategy.box = sinon.stub()
        @strategy.box.withArgs(@data, 300, 200).returns
          x     : 12
          y     : 34
          width : 190
          height: 46
        offset = @strategy.center viewport, @nodes
        expect( offset ).to.have.property 'x', (300 - 190) / 2 - 12
        expect( offset ).to.have.property 'y', (200 - 46 ) / 2 - 34

  describe '#layoutSiblings()', ->

    it 'positions node on the right of sibling', ->
      data = @strategy.layoutSiblings [ sibling: { x: 12, y: 345 } ]
      expect( data[0] ).to.have.property 'x', 112
      expect( data[0] ).to.have.property 'y', 345
