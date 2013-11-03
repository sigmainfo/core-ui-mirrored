#= require spec_helper
#= require collections/concept_map_nodes

describe 'Coreon.Collections.ConceptMapNodes', ->

  beforeEach ->
    @repository = new Backbone.Model
    Coreon.application = repository: => @repository
    sinon.stub Coreon.Models.Concept, 'find'
    @collection = new Coreon.Collections.ConceptMapNodes

  afterEach ->
    Coreon.Models.Concept.find.restore()
    delete Coreon.application

  it 'is a Backbone collection', ->
    @collection.should.be.an.instanceof Coreon.Collections.ConceptMapNodes

  it 'creates ConceptMapNode models', ->
    @collection.reset [ id: 'node' ], silent: yes
    @collection.should.have.lengthOf 1
    @collection.at(0).should.be.an.instanceof Coreon.Models.ConceptMapNode

  describe '#build()', ->

    it 'removes old nodes', ->
      @collection.reset [ id: 'node' ], silent: yes
      node = @collection.at(0)
      @collection.build()
      expect( @collection.get node ).to.not.exist

    it 'creates root node', ->
      @collection.reset [], silent: yes
      @collection.build()
      root = @collection.at(0)
      expect( root ).to.exist
      expect( root.get 'model' ).to.equal @repository

    it 'creates nodes for passed in models', ->
      concept = new Backbone.Model id: 'concept-123'
      @collection.build [ concept ]
      node = @collection.get 'concept-123'
      expect( node ).to.exist
      expect( node.get 'model' ).to.equal concept

    context 'when completely loaded', ->

      beforeEach ->
        @collection.isLoaded = -> yes

      it 'succeeds immediately', ->
        spy = sinon.spy()
        promise = @collection.build()
        promise.done spy
        expect( promise.state() ).to.equal 'resolved'
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledOn @collection
        expect( spy ).to.have.been.calledWith @collection.models

      it 'adds placeholder nodes', ->
        callback = sinon.spy()
        spy = sinon.spy()
        @collection.addPlaceholderNodes = spy
        promise = @collection.build()
        promise.done callback
        expect( spy ).to.have.been.calledOnce
        expect( callback ).to.have.been.calledAfter spy

    context 'when loading parent nodes', ->

      beforeEach ->
        @collection.isLoaded = -> no

      it 'defers callbacks', ->
        spy = sinon.spy()
        promise = @collection.build()
        promise.done spy
        expect( promise.state() ).to.equal 'pending'
        expect( spy ).to.not.have.been.called

      it 'succeeds when all nodes are loaded', ->
        spy = sinon.spy()
        promise = @collection.build()
        promise.done spy
        @collection.isLoaded = -> yes
        @collection.trigger 'change:loaded'
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledOn @collection
        expect( spy ).to.have.been.calledWith @collection.models

      it 'adds placeholder nodes when nodes are loaded', ->
        callback = sinon.spy()
        spy = sinon.spy()
        @collection.addPlaceholderNodes = spy
        promise = @collection.build()
        promise.done callback
        expect( spy ).to.not.have.been.called
        @collection.isLoaded = -> yes
        @collection.trigger 'change:loaded'
        expect( spy ).to.have.been.calledOnce
        expect( callback ).to.have.been.calledAfter spy

      it 'fails when build is called again', ->
        spy = sinon.spy()
        promise = @collection.build()
        nodes = (node for node in @collection.models)
        promise.fail spy
        @collection.build()
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledOn @collection
        expect( spy ).to.have.been.calledWith nodes

      it 'fails if a request is aborted', ->
        spy = sinon.spy()
        promise = @collection.build()
        nodes = (node for node in @collection.models)
        promise.fail spy
        @collection.trigger 'error'
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledOn @collection
        expect( spy ).to.have.been.calledWith nodes

  describe '#isLoaded()', ->

    it 'is true when all nodes are loaded', ->
      @collection.reset [
        { loaded: yes }
        { loaded: yes }
        { loaded: yes }
      ], silent: yes
      expect( @collection.isLoaded() ).to.be.true

    it 'is false when at least one node is not loaded', ->
      @collection.reset [
        { loaded: yes }
        { loaded: no }
        { loaded: yes }
      ], silent: yes
      expect( @collection.isLoaded() ).to.be.false

  describe '#addParentNodes()', ->

    beforeEach ->
      @node = new Backbone.Model
        id: 'sdfg0987'
        parent_node_ids: []
        child_node_ids: []

    it 'is triggered when a node was added', ->
      spy = sinon.spy()
      @collection.addParentNodes = spy
      @collection.initialize()
      @collection.trigger 'add', @node
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledOn @collection
      expect( spy ).to.have.been.calledWith @node

    it 'is triggered when parent node ids change', ->
      spy = sinon.spy()
      @collection.addParentNodes = spy
      @collection.initialize()
      @collection.trigger 'change:parent_node_ids', @node
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledOn @collection
      expect( spy ).to.have.been.calledWith @node

    it 'creates nodes from parent node ids', ->
      concept = new Backbone.Model id: 'sdfg0987'
      Coreon.Models.Concept.find.withArgs('sdfg0987').returns concept
      @node.set 'parent_node_ids', [ 'sdfg0987' ], silent: yes
      @collection.addParentNodes @node
      parent = @collection.get 'sdfg0987'
      expect( parent ).to.exist
      expect( parent.get 'model' ).to.equal concept

    it 'identifies parents of hits', ->
      concept = new Backbone.Model id: 'sdfg0987'
      Coreon.Models.Concept.find.withArgs('sdfg0987').returns concept
      @node.set 'parent_node_ids', [ 'sdfg0987' ], silent: yes
      @collection.addParentNodes @node
      parent = @collection.get 'sdfg0987'
      expect( parent.get 'parent_of_hit' ).to.be.true

  describe '#addPlaceholderNodes()', ->

    it 'creates placeholder for collapsed children', ->
      @collection.reset [
        id: 'fghj567'
        child_node_ids: [ '5678jkl' ]
        expanded: no
      ], silent: yes
      @collection.addPlaceholderNodes()
      node = @collection.at(1)
      expect( node ).to.exist
      expect( node.get 'type' ).to.equal 'placeholder'
      expect( node.id ).to.equal '+[fghj567]'
      expect( node.get 'parent_node_ids' ).to.eql ['fghj567']

    it 'silently adds placeholder', ->
      @collection.reset [
        id: 'fghj567'
        child_node_ids: [ '5678jkl' ]
        expanded: no
      ], silent: yes
      spy = sinon.spy()
      @collection.on "add", spy
      @collection.addPlaceholderNodes()
      expect( spy ).to.not.have.been.called

    it 'does not create placeholder when expanded', ->
      @collection.reset [
        id: 'fghj567'
        child_node_ids: [ '5678jkl' ]
        expanded: yes
      ], silent: yes
      @collection.addPlaceholderNodes()
      node = @collection.get '+[fghj567]'
      expect( node ).to.not.exist

    it 'does not create placeholder when it does not have children', ->
      @collection.reset [
        id: 'fghj567'
        child_node_ids: []
        expanded: no
      ], silent: yes
      @collection.addPlaceholderNodes()
      node = @collection.get '+[fghj567]'
      expect( node ).to.not.exist

    it 'does not create placeholder when there are no more children', ->

      @collection.reset [
        { id: 'fghj567', child_node_ids: [ 'dgfgj67' ] }
        { id: 'dgfgj67', child_node_ids: [] }
      ], silent: yes

      @collection.addPlaceholderNodes()
      node = @collection.get '+[fghj567]'
      expect( node ).to.not.exist

    it 'sets label to hidden children count', ->
      @collection.reset [
        { id: 'fghj567', child_node_ids: [ '5678jkl', 'dgfgj67', 'tzu743a' ] }
        { id: 'dgfgj67', child_node_ids: [] }
      ], silent: yes
      @collection.addPlaceholderNodes()
      node = @collection.get '+[fghj567]'
      expect( node.get 'label' ).to.equal '2'

    it 'does not set label for repository', ->
      @collection.reset [
        id: 'fghj567'
        type: 'repository'
        expanded: no
      ], silent: yes
      @collection.addPlaceholderNodes()
      node = @collection.get '+[fghj567]'
      expect( node.get 'label' ).to.be.null

    it 'default busy state to idle', ->
      @collection.reset [
        id: 'fghj567'
        child_node_ids: [ '5678jkl' ]
        expanded: no
      ], silent: yes
      @collection.addPlaceholderNodes()
      node = @collection.at(1)
      expect( node.get 'busy' ).to.be.false

  describe '#graph()', ->

    beforeEach ->
      sinon.stub Coreon.Lib, 'TreeGraph', =>
        generate: =>
          @graph =
            root:
              children: []
            edges: []

    afterEach ->
      Coreon.Lib.TreeGraph.restore()

    it 'generates tree data structure', ->
      graph = @collection.graph()
      expect( Coreon.Lib.TreeGraph ).to.have.been.calledOnce
      expect( Coreon.Lib.TreeGraph ).to.have.been.calledWithNew
      expect( Coreon.Lib.TreeGraph ).to.have.been.calledWith @collection.models
      expect( graph ).to.equal @graph

  describe '#expand()', ->

    beforeEach ->
      sinon.stub Coreon.Models.Concept, 'roots', =>
        @deferred = $.Deferred()
        @deferred.promise()
      @model = new Backbone.Model id: '8fa451', child_node_ids: []
      @collection.add @model, silent: yes
      @concept1 = new Backbone.Model id: '523345'
      @concept2 = new Backbone.Model id: '4156fe'
      Coreon.Models.Concept.find.withArgs('523345').returns @concept1
      Coreon.Models.Concept.find.withArgs('4156fe').returns @concept2

    afterEach ->
      Coreon.Models.Concept.roots.restore()

    it 'updates expansion state', ->
      @model.set 'expanded', no, silent: yes
      @collection.expand '8fa451'
      expect( @model.get 'expanded' ).to.be.true

    context 'repository', ->

      beforeEach ->
        @model.set 'type', 'repository', silent: yes

      it 'fetches root node ids', ->
        @collection.expand '8fa451'
        expect( Coreon.Models.Concept.roots ).to.have.been.calledOnce

      it 'creates nodes from root node ids', ->
        @collection.expand '8fa451'
        @deferred.resolve ['523345', '4156fe']
        node1 = @collection.get '523345'
        expect( node1 ).to.exist
        expect( node1.get 'model' ).to.equal @concept1
        node2 = @collection.get '4156fe'
        expect( node2 ).to.exist
        expect( node2.get 'model' ).to.equal @concept2

      it 'succeeds immediately if all concepts are already loaded', ->
        spy = sinon.spy()
        @concept1.blank = no
        @concept2.blank = no
        @collection.expand('8fa451').done spy
        @deferred.resolve ['523345', '4156fe']
        node1 = @collection.get '523345'
        node2 = @collection.get '4156fe'
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledWith [node1, node2]

      it 'defers callback if not all concepts are already loaded', ->
        spy = sinon.spy()
        @concept1.blank = no
        @concept2.blank = yes
        @collection.expand('8fa451').done spy
        @deferred.resolve ['523345', '4156fe']
        expect( spy ).to.not.have.been.called

      it 'triggers callback when all concepts are loaded', ->
        spy = sinon.spy()
        @concept1.blank = yes
        @concept2.blank = yes
        @collection.expand('8fa451').done spy
        @deferred.resolve ['523345', '4156fe']
        node1 = @collection.get '523345'
        node1.set 'loaded', yes
        node2 = @collection.get '4156fe'
        node2.set 'loaded', yes
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledWith [node1, node2]

    context 'concept', ->

      beforeEach ->
        @model.set {
          type: 'concept'
          child_node_ids: ['523345', '4156fe']
        }, silent: yes

      it 'does not fetch root node ids', ->
        @collection.expand '8fa451'
        expect( Coreon.Models.Concept.roots ).to.not.have.been.called

      it 'creates nodes from child node ids', ->
        @collection.expand '8fa451'
        node1 = @collection.get '523345'
        expect( node1 ).to.exist
        expect( node1.get 'model' ).to.equal @concept1
        node2 = @collection.get '4156fe'
        expect( node2 ).to.exist
        expect( node2.get 'model' ).to.equal @concept2

      it 'succeeds immediately if all concepts are already loaded', ->
        spy = sinon.spy()
        @concept1.blank = no
        @concept2.blank = no
        @collection.expand('8fa451').done spy
        node1 = @collection.get '523345'
        node2 = @collection.get '4156fe'
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledWith [node1, node2]

      it 'defers callback if not all concepts are already loaded', ->
        spy = sinon.spy()
        @concept1.blank = no
        @concept2.blank = yes
        @collection.expand('8fa451').done spy
        expect( spy ).to.not.have.been.called

      it 'triggers callback when all concepts are loaded', ->
        spy = sinon.spy()
        @concept1.blank = yes
        @concept2.blank = yes
        @collection.expand('8fa451').done spy
        node1 = @collection.get '523345'
        node1.set 'loaded', yes
        node2 = @collection.get '4156fe'
        node2.set 'loaded', yes
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledWith [node1, node2]
