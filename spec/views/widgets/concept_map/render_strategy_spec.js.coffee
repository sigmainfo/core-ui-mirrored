#= require spec_helper
#= require views/widgets/concept_map/render_strategy

describe "Coreon.Views.Widgets.ConceptMap.RenderStrategy", ->

  beforeEach ->
    @svg = $('<svg:g class="map">')
    @parent = d3.select @svg[0]
    loops = []
    @parent.startLoop = (callback) -> loops.push callback
    @parent.stopLoop = -> loops = []
    @nextFrame = -> callback arguments... for callback in loops
    sinon.stub d3.layout, 'tree', => @layout =
      nodes: sinon.stub().returns []
    sinon.stub d3.svg, 'diagonal', => @diagonal = {}
    @strategy = new Coreon.Views.Widgets.ConceptMap.RenderStrategy @parent, d3.layout.tree()
    sinon.stub _, 'defer', (@deferred) =>

  afterEach ->
    d3.layout.tree.restore()
    d3.svg.diagonal.restore()
    _.defer.restore()

  describe '#constructor()', ->

    it 'stores reference to parent selection', ->
      @strategy.should.have.deep.property 'parent', @parent

    it 'creates layout instance', ->
      @strategy.should.have.property 'layout', @layout

    it 'creates stencil for drawing edges', ->
      @strategy.should.have.property 'diagonal', @diagonal

  describe '#resize()', ->

    it 'sets width and height values', ->
      @strategy.resize 320, 240
      @strategy.should.have.property 'width', 320
      @strategy.should.have.property 'height', 240

  describe '#render()', ->

    beforeEach ->
      @clock = sinon.useFakeTimers()
      @graph =
        tree: {}
        edges: {}

    afterEach ->
      @clock.restore()

    it 'renders nodes', ->
      @strategy.renderNodes = sinon.spy()
      @strategy.render @graph
      @clock.tick 500
      @strategy.renderNodes.should.have.been.calledOnce
      @strategy.renderNodes.should.have.been.calledWith @graph.tree

    it 'renders edges', ->
      @strategy.renderEdges = sinon.spy()
      @strategy.render @graph
      @clock.tick 500
      @strategy.renderEdges.should.have.been.calledOnce
      @strategy.renderEdges.should.have.been.calledWith @graph.edges

    it 'defers update of layout', ->
      nodes = []
      edges = []
      @strategy.updateLayout = sinon.spy()
      @strategy.renderNodes = -> nodes
      @strategy.renderEdges = -> edges
      @strategy.render @graph
      @clock.tick 500
      @strategy.updateLayout.should.not.have.been.called
      _.defer.should.have.been.calledWith @strategy.updateLayout, nodes, edges

  describe '#renderNodes()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'repositoryPath'
      @parent.append('g')
        .attr('class', 'concept-node')
        .datum(id: 'remove', type: 'concept')
      @parent.append('g')
        .attr('class', 'concept-node', type: 'concept')
        .datum(id: 'update')
      @data = [
        { id: 'root', type: 'repository' }
        { id: 'create', type: 'concept' }
        { id: 'update', type: 'concept' }
      ]
      @root = @data[0]
      @root.children = @data[1..]
      @layout.nodes.withArgs(@root).returns @data

    afterEach ->
      Coreon.Helpers.repositoryPath.restore()

    it 'maps nodes to data', ->
      nodes = @strategy.renderNodes @root
      nodes.data().should.eql @data

    it 'creates missing nodes including root node', ->
      @strategy.createNodes = sinon.spy()
      enter = @strategy.renderNodes(@root).enter()
      ids = (node.__data__.id for i, node of enter[0] when node.__data__?)
      ids.should.eql [ 'root', 'create' ]
      @strategy.createNodes.should.have.been.calledOnce
      @strategy.createNodes.should.have.been.calledWith enter

    it 'deletes deprecated nodes', ->
      @strategy.deleteNodes = sinon.spy()
      exit = @strategy.renderNodes(@root).exit()
      ids = (node.__data__.id for i, node of exit[0] when node.__data__?)
      ids.should.eql [ 'remove' ]
      @strategy.deleteNodes.should.have.been.calledOnce
      @strategy.deleteNodes.should.have.been.calledWith exit

    it 'updates all nodes', ->
      @strategy.updateNodes = sinon.spy()
      nodes = @strategy.renderNodes @root
      @strategy.updateNodes.should.have.been.calledOnce
      @strategy.updateNodes.should.have.been.calledWith nodes

  describe '#createNodes()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'repositoryPath'
      @enter = @parent
        .selectAll('.concept-node')
        .data([
          { id: 'repository'  , type: 'repository'  , path: '/my-repo' }
          { id: 'concept'     , type: 'concept'     , path: '/path-to-concept' }
          { id: 'placeholder' , type: 'placeholder' , path: 'javascript:void(0)' }
        ])
        .enter()

    afterEach ->
      Coreon.Helpers.repositoryPath.restore()

    it 'returns selection of newly created nodes', ->
      nodes = @strategy.createNodes @enter
      nodes.node().should.equal @parent.select('.concept-node').node()

    it 'appends concept node container', ->
      @strategy.createNodes @enter
      @parent.selectAll('g.concept-node')[0].should.have.lengthOf 3

    it 'classifies repository node', ->
      @strategy.createNodes @enter
      node = @parent.selectAll('.concept-node').filter(
        (datum) -> datum.type is 'repository'
      )
      node.attr('class').split(' ').should.include 'repository-root'

    context 'regular nodes', ->

      it 'renders link', ->
        @strategy.createNodes @enter
        concept = @parent.selectAll('.concept-node').filter(
          (datum) -> datum.type is 'concept'
        )
        link = concept.select('a')
        should.exist link.node()
        link.attr('xlink:href').should.equal '/path-to-concept'

      it 'renders bullet', ->
        @strategy.createNodes @enter
        bullet = @parent.select('.concept-node a circle.bullet')
        should.exist bullet.node()

      it 'renders empty label', ->
        @strategy.createNodes @enter
        label = @parent.select('.concept-node a text.label')
        should.exist label.node()

      it 'inserts background', ->
        @strategy.createNodes @enter
        bg = @parent.select('.concept-node a rect.background')
        should.exist bg.node()

      it 'renders title', ->
        @strategy.createNodes @enter
        title = @parent.select('.concept-node title')
        should.exist title.node()

      it 'is not classified as placeholder', ->
        @strategy.createNodes @enter
        node = @parent.selectAll('.concept-node').filter(
          (datum) -> datum.type isnt 'placeholder'
        )
        node.attr('class').split(' ').should.not.include 'placeholder'

    context 'placeholder nodes', ->

      beforeEach ->
        @strategy.createNodes @enter
        @placeholder = @parent.selectAll('.concept-node').filter(
          (datum) -> datum.type is 'placeholder'
        )

      it 'classifies nodes', ->
        @placeholder.attr('class').split(' ').should.include 'placeholder'

      it 'renders background', ->
        background = @placeholder.select('circle.background')
        should.exist background.node()

      it 'renders icon', ->
        icon = @placeholder.select('path.icon')
        should.exist icon.node()

      it 'renders progress indicator', ->
        indicator = @placeholder.select('g.progress-indicator')
        should.exist indicator.node()
        track = indicator.select('circle.track')
        should.exist track.node()
        track.attr('r').should.equal '6'
        cursor = indicator.select('path.cursor')
        should.exist cursor.node()
        cursor.attr('d').should.equal 'M 6 0 A 6 6 0 0 1 3 5.19'

      it 'does not create title element', ->
        should.not.exist @placeholder.select('title').node()

      it 'does not create link', ->
        should.not.exist @placeholder.select('a').node()

  describe '#deleteNodes()', ->

    beforeEach ->
      @animation = duration: 123
      @parent.append('g')
        .attr('class', 'concept-node placeholder')
        .datum(id: 'remove', type: 'placeholder', loop: @animation)
      @exit = @parent.selectAll('.concept-node')
        .data([])
        .exit()

    it 'stops loop of placeholders', ->
      @parent.stopLoop = sinon.spy()
      @strategy.deleteNodes @exit
      @parent.stopLoop.should.have.been.calledOnce
      @parent.stopLoop.should.have.been.calledWith @animation

    it 'removes nodes', ->
      @exit.remove = sinon.spy()
      @strategy.deleteNodes @exit
      @exit.remove.should.have.been.calledOnce

  describe '#updateNodes()', ->

    beforeEach ->
      @selection = @parent.append('g').attr('class', 'concept-node')

    context 'regular nodes', ->

      it 'can be chained', ->
        nodes = @selection.data []
        @strategy.updateNodes(nodes).should.equal nodes

      it 'classifies hits', ->
        nodes = @selection.data [
          hit: yes
        ]
        @strategy.updateNodes nodes
        nodes.attr('class').split(' ').should.include 'hit'

      it 'classifies parents of hit', ->
        nodes = @selection.data [
          parent_of_hit: yes
        ]
        @strategy.updateNodes nodes
        nodes.attr('class').split(' ').should.include 'parent-of-hit'

      it 'classifies new concepts', ->
        nodes = @selection.data [
          id: null
        ]
        @strategy.updateNodes nodes
        nodes.attr('class').split(' ').should.include 'new'

      it 'does not classify ordinary nodes', ->
        nodes = @selection.data [
          id: 'node1'
          hit: no
        ]
        @strategy.updateNodes nodes
        classNames = nodes.attr('class').split(' ')
        classNames.should.not.include 'hit'
        classNames.should.not.include 'new'

      it 'updates title', ->
        title = @selection.append('title')
        nodes = @selection.data [
          label: 'node 123'
        ]
        @strategy.updateNodes nodes
        title.text().should.equal 'node 123'

      it 'updates bullet size depending on hit status', ->
        bullet = @selection.append('circle').attr('class', 'bullet')
        nodes = @selection.data [
          hit: no
        ]
        @strategy.updateNodes nodes
        bullet.attr('r').should.equal '2.5'
        nodes = @selection.data [
          hit: yes
        ]
        @strategy.updateNodes nodes
        bullet.attr('r').should.equal '2.8'

      it 'applies drop shadow depending on hit status', ->
        background = @selection.append('rect').attr('class', 'background')
        nodes = @selection.data [
          hit: yes
        ]
        @strategy.updateNodes nodes
        background.attr('filter').should.equal 'url(#coreon-drop-shadow-filter)'
        nodes = @selection.data [
          hit: no
        ]
        @strategy.updateNodes nodes
        should.not.exist background.attr('filter')

      it 'rounds corners of root node', ->
        background = @selection.append('rect').attr('class', 'background')
        nodes = @selection.data [
          type: 'repository'
        ]
        @strategy.updateNodes nodes
        background.attr('rx').should.eql '5'
        nodes = @selection.data [
          type: 'concept'
        ]
        @strategy.updateNodes nodes
        should.not.exist background.attr('rx')

    context 'placeholders', ->

      context 'idle', ->

        it 'classifies as idle', ->
          nodes = @selection.data [
            type: 'placeholder'
            busy: no
          ]
          @strategy.updateNodes nodes
          classes = @selection.attr('class').split ' '
          expect( classes ).to.not.contain 'busy'

        it 'resets background radius', ->
          background = @selection.append('circle').attr('class', 'background')
          nodes = @selection.data [
            type: 'placeholder'
            busy: no
          ]
          @strategy.updateNodes nodes
          background.attr('r').should.equal '7'

        it 'shows icon', ->
          icon = @selection.append('path').attr('class', 'icon')
          nodes = @selection.data [
            type: 'placeholder'
            busy: no
          ]
          @strategy.updateNodes nodes
          should.not.exist icon.attr('style')

        it 'hides progress indicator', ->
          indicator = @selection.append('g').attr('class', 'progress-indicator')
          nodes = @selection.data [
            type: 'placeholder'
            busy: no
          ]
          @strategy.updateNodes nodes
          indicator.attr('style').should.include 'display: none;'

        it 'does not start animation loop', ->
          cursor = @selection.append('path').attr('class', 'cursor')
          nodes = @selection.data [
            type: 'placeholder'
            busy: no
            loop: null
          ]
          @strategy.updateNodes nodes
          @nextFrame duration: 30
          should.not.exist cursor.attr('transform')

        it 'stops running animation loop', ->
          cursor = @selection.append('path').attr('class', 'cursor')
          animation = duration: 12
          @parent.stopLoop = sinon.spy()
          nodes = @selection.data [
            type: 'placeholder'
            busy: no
            loop: animation
          ]
          @strategy.updateNodes nodes
          @parent.stopLoop.should.have.been.calledOnce
          @parent.stopLoop.should.have.been.calledWith animation

        it 'does not stop loop that does not exist', ->
          cursor = @selection.append('path').attr('class', 'cursor')
          @parent.stopLoop = sinon.spy()
          nodes = @selection.data [
            type: 'placeholder'
            busy: no
            loop: null
          ]
          @strategy.updateNodes nodes
          expect( @parent.stopLoop ).to.not.have.been.called


      context 'busy', ->

        it 'classifies as busy', ->
          nodes = @selection.data [
            type: 'placeholder'
            busy: yes
          ]
          @strategy.updateNodes nodes
          classes = @selection.attr('class').split ' '
          expect( classes ).to.contain 'busy'

        it 'increases background radius', ->
          background = @selection.append('circle').attr('class', 'background')
          nodes = @selection.data [
            type: 'placeholder'
            busy: yes
          ]
          @strategy.updateNodes nodes
          background.attr('r').should.equal '10'

        it 'hides icon', ->
          icon = @selection.append('path').attr('class', 'icon')
          nodes = @selection.data [
            type: 'placeholder'
            busy: yes
          ]
          @strategy.updateNodes nodes
          icon.attr('style').should.include 'display: none;'

        it 'shows progress indicator', ->
          indicator = @selection.append('g').attr('class', 'progress-indicator')
          nodes = @selection.data [
            type: 'placeholder'
            busy: yes
          ]
          @strategy.updateNodes nodes
          should.not.exist indicator.attr('style')

        it 'starts animation loop', ->
          cursor = @selection.append('path').attr('class', 'cursor')
          nodes = @selection.data [
            type: 'placeholder'
            busy: yes
          ]
          @strategy.updateNodes nodes
          @nextFrame duration: 30
          cursor.attr('transform').should.equal 'rotate(12)'

        it 'does not start animation more than once', ->
          cursor = @selection.append('path').attr('class', 'cursor')
          animation = duration: 12
          @parent.startLoop = sinon.spy()
          nodes = @selection.data [
            type: 'placeholder'
            busy: yes
            loop: animation
          ]
          @strategy.updateNodes nodes
          @parent.startLoop.should.not.have.been.called


  describe '#renderEdges()', ->

    beforeEach ->
      source = id: 'source'
      remove = id: 'remove'
      update = id: 'update'
      create = id: 'create'
      @parent.append('g')
        .attr('class', 'concept-edge')
        .datum(
          source: source
          target: remove
        )
      @parent.append('g')
        .attr('class', 'concept-edge')
        .datum(
          source: source
          target: update
        )
      @edges = [
        { source: source, target: create }
        { source: source, target: update }
      ]

    it 'creates missing edges', ->
      @strategy.createEdges = sinon.spy()
      enter = @strategy.renderEdges(@edges).enter()
      data = (edge.__data__ for i, edge of enter[0] when edge.__data__?)
      data.should.eql [
        source: id: 'source'
        target: id: 'create'
      ]
      @strategy.createEdges.should.have.been.calledOnce
      @strategy.createEdges.should.have.been.calledWith enter

    it 'deletes deprecated edges', ->
      @strategy.deleteEdges = sinon.spy()
      exit = @strategy.renderEdges(@edges).exit()
      data = (edge.__data__ for i, edge of exit[0] when edge.__data__?)
      data.should.eql [
        source: id: 'source'
        target: id: 'remove'
      ]
      @strategy.deleteEdges.should.have.been.calledOnce
      @strategy.deleteEdges.should.have.been.calledWith exit

    it 'updates all edges', ->
      @strategy.updateEdges = sinon.spy()
      edges = @strategy.renderEdges @edges
      @strategy.updateEdges.should.have.been.calledOnce
      @strategy.updateEdges.should.have.been.calledWith edges

  describe '#createEdges()', ->

    beforeEach ->
      @enter = @parent
        .selectAll('.concept-edge')
        .data([ source: {id: 'parent'}, target: {id: 'child'} ])
        .enter()

    it 'inserts path', ->
      @strategy.createEdges @enter
      should.exist @parent.select('path.concept-edge').node()

    it 'returns selection of newly created paths', ->
      paths = @strategy.createEdges @enter
      paths.node().should.equal @parent.select('.concept-edge').node()

  describe '#deleteEdges()', ->

    it 'removes paths', ->
      exit = remove: sinon.spy()
      @strategy.deleteEdges exit
      exit.remove.should.have.been.calledOnce
