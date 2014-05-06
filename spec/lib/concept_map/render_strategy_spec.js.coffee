#= require spec_helper
#= require lib/concept_map/render_strategy

describe "Coreon.Lib.ConceptMap.RenderStrategy", ->

  beforeEach ->
    @svg = $('<svg:g class="map">')
    @parent = d3.select @svg[0]
    loops = []
    @parent.startLoop = (callback) -> loops.push callback
    @parent.stopLoop = -> loops = []
    @nextFrame = -> callback arguments... for callback in loops
    @stub d3.layout, 'tree', => @layout =
      nodes: @stub().returns []
    @stub d3.svg, 'diagonal', => @diagonal = {}
    @strategy = new Coreon.Lib.ConceptMap.RenderStrategy @parent, d3.layout.tree()
    @stub _, 'defer', (@deferred) =>

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
      @graph =
        tree     : {}
        edges    : {}
        siblings : []
      @strategy.renderNodes = @spy -> data: -> []
      @strategy.renderSiblings = @spy -> data: -> []

    it 'renders nodes', ->
      @strategy.render @graph
      @strategy.renderNodes.should.have.been.calledOnce
      @strategy.renderNodes.should.have.been.calledWith @graph.tree

    it 'renders siblings', ->
      @strategy.render @graph
      @strategy.renderSiblings.should.have.been.calledOnce
      @strategy.renderSiblings.should.have.been.calledWith @graph.siblings
      renderNodes = @strategy.renderNodes
      @strategy.renderSiblings.should.have.been.calledAfter renderNodes

    it 'renders edges', ->
      @strategy.renderEdges = @spy()
      @strategy.render @graph
      @strategy.renderEdges.should.have.been.calledOnce
      @strategy.renderEdges.should.have.been.calledWith @graph.edges

    it 'defers update of layout', ->
      deferred = promise: ->
      @stub $, 'Deferred', -> deferred
      nodes = ['node']
      nodes.data = -> nodes
      siblings = ['sibling']
      siblings.data = -> siblings
      edges = []
      selection = @strategy.parent.selectAll '.concept-node, .sibling-node'
      selection.data = @stub()
      selection.data.withArgs(['node', 'sibling']).returns selection
      @strategy.updateLayout = @spy()
      @strategy.renderNodes = -> nodes
      @strategy.renderSiblings = -> siblings
      @strategy.renderEdges = -> edges
      @strategy.parent.selectAll = @stub()
      @strategy.parent.selectAll
        .withArgs('.concept-node, .sibling-node')
        .returns selection
      @strategy.render @graph
      expect( @strategy.updateLayout ).to.not.have.been.called
      expect( _.defer ).to.have.been.calledOnce
      expect( _.defer ).to.have.been.calledWith @strategy.updateLayout
      expect( _.defer.firstCall.args[2] ).to.have.equal edges
      expect( _.defer.firstCall.args[3] ).to.have.equal deferred
      identify = selection.data.firstCall.args[1]
      expect( identify( id: '1234' ) ).to.equal '1234'
      expect( _.defer.firstCall.args[1] ).to.equal selection

    it 'returns promise', ->
      promise = {}
      deferred = promise: -> promise
      @stub $, 'Deferred', -> deferred
      expect( @strategy.render @graph ).to.equal promise

  describe '#renderNodes()', ->

    beforeEach ->
      @stub Coreon.Helpers, 'repositoryPath'
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

    it 'maps nodes to data', ->
      nodes = @strategy.renderNodes @root
      nodes.data().should.eql @data

    it 'creates missing nodes including root node', ->
      @strategy.createNodes = @spy()
      enter = @strategy.renderNodes(@root).enter()
      ids = (node.__data__.id for i, node of enter[0] when node.__data__?)
      ids.should.eql [ 'root', 'create' ]
      @strategy.createNodes.should.have.been.calledOnce
      @strategy.createNodes.should.have.been.calledWith enter

    it 'deletes deprecated nodes', ->
      @strategy.deleteNodes = @spy()
      exit = @strategy.renderNodes(@root).exit()
      ids = (node.__data__.id for i, node of exit[0] when node.__data__?)
      ids.should.eql [ 'remove' ]
      @strategy.deleteNodes.should.have.been.calledOnce
      @strategy.deleteNodes.should.have.been.calledWith exit

    it 'updates all nodes', ->
      @strategy.updateNodes = @spy()
      nodes = @strategy.renderNodes @root
      @strategy.updateNodes.should.have.been.calledOnce
      @strategy.updateNodes.should.have.been.calledWith nodes

  describe '#renderSiblings()', ->

    beforeEach ->
      @parent.append('g')
        .attr('class', 'sibling-node')
        .datum(id: 'remove', type: 'placeholder')
      @parent.append('g')
        .attr('class', 'sibling-node', type: 'placeholder')
        .datum(id: 'update')
      @data = [
        { id: 'create', type: 'placeholder' }
        { id: 'update', type: 'placeholder' }
      ]
      @strategy.layoutSiblings = @stub()
      @strategy.layoutSiblings.withArgs(@data).returns @data

    it 'maps nodes to data', ->
      nodes = @strategy.renderSiblings @data
      nodes.data().should.eql @data

    it 'creates missing nodes including root node', ->
      @strategy.createNodes = @spy()
      nodes = @strategy.renderSiblings @data
      enter = nodes.enter()
      ids = (node.__data__.id for i, node of enter[0] when node.__data__?)
      ids.should.eql [ 'create' ]
      @strategy.createNodes.should.have.been.calledOnce
      @strategy.createNodes.should.have.been.calledWith enter

    it 'deletes deprecated nodes', ->
      @strategy.deleteNodes = @spy()
      nodes = @strategy.renderSiblings @data
      exit = nodes.exit()
      ids = (node.__data__.id for i, node of exit[0] when node.__data__?)
      ids.should.eql [ 'remove' ]
      @strategy.deleteNodes.should.have.been.calledOnce
      @strategy.deleteNodes.should.have.been.calledWith exit

    it 'updates all nodes', ->
      @strategy.updateNodes = @spy()
      nodes = @strategy.renderSiblings @data
      @strategy.updateNodes.should.have.been.calledOnce
      @strategy.updateNodes.should.have.been.calledWith nodes

  describe '#createNodes()', ->

    beforeEach ->
      @stub Coreon.Helpers, 'repositoryPath'
      @enter = @parent
        .selectAll('.concept-node')
        .data([
          { id: 'repository'  , type: 'repository'  , path: '/my-repo' }
          { id: 'concept'     , type: 'concept'     , path: '/path-to-concept' }
          { id: 'placeholder' , type: 'placeholder' , path: 'javascript:void(0)' }
        ])
        .enter()

    it 'returns selection of newly created nodes', ->
      nodes = @strategy.createNodes @enter
      nodes.node().should.equal @parent.select('.concept-node').node()

    it 'appends concept node container', ->
      @strategy.createNodes @enter
      @parent.selectAll('g.concept-node')[0].should.have.lengthOf 3

    it 'appends sibling node container', ->
      @enter = @parent
        .selectAll('.sibling-node')
        .data([
          { id: 'sibling-a', type: 'placeholder', sibling: {} }
          { id: 'sibling-b', type: 'placeholder', sibling: {} }
        ])
        .enter()
      @strategy.createNodes @enter
      @parent.selectAll('g.sibling-node')[0].should.have.lengthOf 2

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

      it 'creates empty title', ->
        title = @placeholder.select('title')
        expect( title.node() ).to.exist

      it 'creates empty count', ->
        label = @placeholder.select('text.count')
        expect( label.node() ).to.exist
        expect( label.attr('text-anchor') ).to.equal 'start'
        expect( label.attr('x') ).to.equal '18'
        expect( label.attr('y') ).to.equal '4'

      it 'renders background for count', ->
        background = @placeholder.select('rect.count-background')
        expect( background.node() ).to.exist
        expect( background.attr('height') ).to.equal '1.1em'
        expect( background.attr('rx') ).to.equal '0.5em'
        expect( background.attr('x') ).to.equal '12'
        expect( background.attr('y') ).to.equal '-0.55em'

      it 'renders circle', ->
        background = @placeholder.select('circle.background')
        expect( background.node() ).to.exist

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
      @parent.stopLoop = @spy()
      @strategy.deleteNodes @exit
      @parent.stopLoop.should.have.been.calledOnce
      @parent.stopLoop.should.have.been.calledWith @animation

    it 'removes nodes', ->
      @exit.remove = @spy()
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

      it 'updates title', ->
        I18n.t.withArgs('panels.concept_map.placeholder.title',
          count: 123
          label: 'Billiards'
        ).returns '123 more concepts for Billiards'
        title = @selection.append('title')
        nodes = @selection.data [
          type: 'placeholder'
          label: '123'
          parent:
            label: 'Billiards'
        ]
        @strategy.updateNodes nodes
        expect( title.text() ).to.equal '123 more concepts for Billiards'

      it 'updates count', ->
        count = @selection.append('text').attr('class', 'count')
        nodes = @selection.data [
          type: 'placeholder'
          label: '123'
        ]
        @strategy.updateNodes nodes
        expect( count.text() ).to.equal '123'

      it 'hides background when not given', ->
        count = @selection.append('rect').attr('class', 'count-background')
        nodes = @selection.data [
          type: 'placeholder'
          label: null
        ]
        @strategy.updateNodes nodes
        expect( count.attr('style') ).to.contain 'display: none'

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
          @parent.stopLoop = @spy()
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
          @parent.stopLoop = @spy()
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
          @parent.startLoop = @spy()
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
      @strategy.createEdges = @spy()
      enter = @strategy.renderEdges(@edges).enter()
      data = (edge.__data__ for i, edge of enter[0] when edge.__data__?)
      data.should.eql [
        source: id: 'source'
        target: id: 'create'
      ]
      @strategy.createEdges.should.have.been.calledOnce
      @strategy.createEdges.should.have.been.calledWith enter

    it 'deletes deprecated edges', ->
      @strategy.deleteEdges = @spy()
      exit = @strategy.renderEdges(@edges).exit()
      data = (edge.__data__ for i, edge of exit[0] when edge.__data__?)
      data.should.eql [
        source: id: 'source'
        target: id: 'remove'
      ]
      @strategy.deleteEdges.should.have.been.calledOnce
      @strategy.deleteEdges.should.have.been.calledWith exit

    it 'updates all edges', ->
      @strategy.updateEdges = @spy()
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
      exit = remove: @spy()
      @strategy.deleteEdges exit
      exit.remove.should.have.been.calledOnce

  describe '#updateLayout()', ->

    beforeEach ->
      @selection = @parent.append('g').attr('class', 'concept-node placeholder')
      @nodes = @selection.data [
        type: 'placeholder'
        label: 'node 12345'
      ]

    it 'resizes background of count', ->
      label = @selection.append('text').attr('class', 'count')
      label.node().getBBox = -> width: 100
      background = @selection.append('rect').attr('class', 'count-background')
      @strategy.updateLayout @nodes, null, resolve: ->
      background.attr('width').should.equal '112'

    it 'reolves passed in deferred', ->
      deferred = resolve: @spy()
      edges = []
      @strategy.updateLayout @nodes, edges, deferred
      expect( deferred.resolve ).to.have.been.calledOnce
      expect( deferred.resolve ).to.have.been.calledWith @nodes, edges

  describe '#box()', ->

    context 'without nodes', ->

      beforeEach ->
        @data = []

      it 'returns origin', ->
        box = @strategy.box @data, 300, 200
        expect( box ).to.have.property 'x', 0
        expect( box ).to.have.property 'y', 0

      it 'returns zero extent box', ->
        box = @strategy.box @data, @viewport
        expect( box ).to.have.property 'width', 0
        expect( box ).to.have.property 'height', 0

    context 'single node', ->

      beforeEach ->
        @data = [ x: 23, y: 45 ]

      it 'returns node position', ->
        box = @strategy.box @data, 300, 200
        expect( box ).to.have.property 'x', 23
        expect( box ).to.have.property 'y', 45

      it 'returns zero extent box', ->
        box = @strategy.box @data, @viewport
        expect( box ).to.have.property 'width', 0
        expect( box ).to.have.property 'height', 0

    context 'multiple hits', ->

      beforeEach ->
        @data = [
          { x:  23,  y: 145 }
          { x:  53,  y: -26 }
          { x:  12,  y:  32 }
        ]

      it 'calculates top left corner for coordinates', ->
        box = @strategy.box @data, 300, 200
        expect( box ).to.have.property 'x', 12
        expect( box ).to.have.property 'y', -26

      it 'calculates width and height from min and max coordinates', ->
        box = @strategy.box @data, 300, 200
        expect( box ).to.have.property 'width', 41
        expect( box ).to.have.property 'height', 171

    context 'exceeding viewport', ->

      beforeEach ->
        @data = [
          { x: 34,  y: -12 }
          { x: 53,  y: -26 }
          { x: 23,  y: 145 }
          { x: 123, y:  32 }
        ]

      it 'only takes top scored hits into account', ->
        box = @strategy.box @data, 80, 200
        expect( box ).to.have.property 'x', 23
        expect( box ).to.have.property 'y', -26
        expect( box ).to.have.property 'width', 30
        expect( box ).to.have.property 'height', 171
