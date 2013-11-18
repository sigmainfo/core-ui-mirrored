#= require spec_helper
#= require collections/concept_map_nodes

describe 'Coreon.Collections.ConceptMapNodes', ->

  beforeEach ->
    @repository = new Backbone.Model
    Coreon.application = repository: => @repository
    sinon.stub Coreon.Models.Concept, 'find'
    sinon.stub Coreon.Models.Concept, 'roots', =>
      @deferred = $.Deferred()
      @deferred.promise()
    @collection = new Coreon.Collections.ConceptMapNodes

  afterEach ->
    Coreon.Models.Concept.find.restore()
    Coreon.Models.Concept.roots.restore()
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

    it 'sets top level concept ids on root', ->
      deferred = $.Deferred()
      @collection.rootIds = -> deferred.promise()
      @collection.build()
      deferred.resolve ['8fa451', '4156fe']
      root = @collection.at(0)
      expect( root.get 'child_node_ids' ).to.eql ['8fa451', '4156fe']

    it 'updates placeholders when updating root ids after build', ->
      deferred = $.Deferred()
      @collection.rootIds = -> deferred.promise()
      update = @collection.updatePlaceholderNode = sinon.spy()
      @collection.build()
      delete @collection.build.deferred
      update.reset()
      deferred.resolve ['8fa451', '4156fe']
      root = @collection.at(0)
      expect( update ).to.have.been.calledOnce
      expect( update ).to.have.been.calledWith root, ['8fa451', '4156fe']

    it 'it does not update placeholders when setting root ids during build', ->
      deferred = $.Deferred()
      @collection.rootIds = -> deferred.promise()
      update = @collection.updatePlaceholderNode = sinon.spy()
      @collection.build()
      @collection.build.deferred = $.Deferred()
      update.reset()
      deferred.resolve ['8fa451', '4156fe']
      root = @collection.at(0)
      expect( update ).to.not.have.been.called

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
        @collection.updateAllPlaceholderNodes = spy
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
        @collection.updateAllPlaceholderNodes = spy
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

    it 'is false when at least one node is not yet loaded', ->
      @collection.reset [
        { loaded: yes }
        { loaded: no }
        { loaded: yes }
      ], silent: yes
      expect( @collection.isLoaded() ).to.be.false

  describe '#rootIds()', ->

    it 'fetches root ids', ->
      @collection.rootIds()
      expect( Coreon.Models.Concept.roots ).to.have.been.calledOnce

    it 'resolves with root ids', ->
      spy = sinon.spy()
      @collection.rootIds().done spy
      @deferred.resolve ['8fa451', '4156fe']
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledWith ['8fa451', '4156fe']

    it 'memoizes root ids', ->
      spy = sinon.spy()
      @collection.rootIds().done spy
      @deferred.resolve ['8fa451', '4156fe']
      @collection.rootIds()
      expect( Coreon.Models.Concept.roots ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledWith ['8fa451', '4156fe']

    it 'can be forced to fetch root ids again', ->
      spy = sinon.spy()
      @collection.rootIds()
      @deferred.resolve ['8fa451', '4156fe']
      @collection.rootIds(yes).done spy
      @deferred.resolve []
      expect( Coreon.Models.Concept.roots ).to.have.been.calledTwice
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledWith []

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

  describe '#updateAllPlaceholderNodes()', ->

    it 'silently updates every single model', ->
      update = @collection.updatePlaceholderNode = sinon.spy()
      node1 = new Backbone.Model id: 'fghj567', child_node_ids: ['58765fh']
      node2 = new Backbone.Model id: '58765fh', child_node_ids: []
      @collection.reset [
        node1
        node2
      ], silent: yes
      @collection.updateAllPlaceholderNodes()
      expect( update ).to.have.been.calledTwice
      expect( update ).to.have.been.calledWith node1, ['58765fh'], silent: yes
      expect( update ).to.have.been.calledWith node2, [], silent: yes

    it 'does not call update on placeholders itself', ->
      update = @collection.updatePlaceholderNode = sinon.spy()
      node1 = new Backbone.Model id: 'fghj567', type: 'concept', child_node_ids: []
      node2 = new Backbone.Model id: '58765fh', type: 'placeholder', child_node_ids: []
      @collection.reset [
        node1
        node2
      ], silent: yes
      @collection.updateAllPlaceholderNodes()
      expect( update ).to.have.been.calledOnce

  describe '#updatePlaceholderNode()', ->

    beforeEach ->
      @node = new Backbone.Model id: 'fghj567', child_node_ids: []

    it 'creates placeholder for children', ->
      @node.id = 'fghj567'
      @collection.updatePlaceholderNode @node, ['5678jkl']
      placeholder = @collection.at(0)
      expect( placeholder.get 'type' ).to.equal 'placeholder'
      expect( placeholder.id ).to.equal '+[fghj567]'

    it 'silently adds placeholder', ->
      spy = sinon.spy()
      @collection.on "add", spy
      @collection.updatePlaceholderNode @node, ['5678jkl']
      expect( spy ).to.not.have.been.called

    it 'sets label to hidden children count', ->
      @collection.reset [ id: '5678jkl' ], silent: yes
      @collection.updatePlaceholderNode @node, ['5678jkl', '4522hf']
      placeholder = @collection.get "+[fghj567]"
      expect( placeholder.get 'label' ).to.equal '1'

    it 'removes placeholder when child nodes are empty', ->
      @collection.reset [
        id: '+[fghj567]'
      ], silent: yes
      @collection.updatePlaceholderNode @node, []
      placeholder = @collection.get "+[fghj567]"
      expect( placeholder ).to.not.exist

    it 'removes placeholder when no more children are hidden', ->
      @collection.reset [
        { id: '+[fghj567]' }
        { id: '5678jkl'    }
      ], silent: yes
      @collection.updatePlaceholderNode @node, ['5678jkl']
      placeholder = @collection.get "+[fghj567]"
      expect( placeholder ).to.not.exist

    it 'updates existing placeholder', ->
      @collection.reset [
        id: '+[fghj567]'
        child_node_ids: ['5678jkl']
      ], silent: yes
      @collection.updatePlaceholderNode @node, ['5678jkl', '4522hf' ]
      placeholder = @collection.get "+[fghj567]"
      expect( placeholder.get 'label' ).to.equal '2'

    context 'events', ->

      it 'triggers event', ->
        spy = sinon.spy()
        @collection.on 'placeholder:update', spy
        @collection.updatePlaceholderNode @node, ['5678jkl']
        expect( spy ).to.have.been.calledOnce

      it 'does not trigger event when silent', ->
        spy = sinon.spy()
        @collection.on 'placeholder:update', spy
        @collection.updatePlaceholderNode @node, ['5678jkl'], silent: yes
        expect( spy ).to.not.have.been.called

    context 'repository root', ->

      it 'enforces placeholder on repository whith unknown root ids', ->
        @node.set 'type', 'repository', silent: yes
        @collection.updatePlaceholderNode @node, []
        placeholder = @collection.get "+[fghj567]"
        expect( placeholder ).to.exist

      it 'does not enforce placeholder on repository whith known root ids', ->
        @node.set 'type', 'repository', silent: yes
        @collection._rootIds = ['523345', '58765fh']
        @collection.updatePlaceholderNode @node, []
        placeholder = @collection.get "+[fghj567]"
        expect( placeholder ).to.not.exist

    context 'with siblings', ->

      it 'does not connect to parent', ->
        @collection.reset [ id: '5678jkl' ], silent: yes
        @collection.updatePlaceholderNode @node, ['5678jkl', '4522hf']
        placeholder = @collection.get "+[fghj567]"
        expect( placeholder.get 'parent_node_ids' ).to.eql []

      it 'connects to siblings', ->
        @collection.reset [ id: '5678jkl' ], silent: yes
        @collection.updatePlaceholderNode @node, ['5678jkl', '4522hf']
        placeholder = @collection.get "+[fghj567]"
        expect( placeholder.get 'sibling_node_ids' ).to.eql ['5678jkl']

    context 'without siblings', ->

      it 'connects to parent', ->
        @collection.reset [], silent: yes
        @collection.updatePlaceholderNode @node, ['5678jkl', '4522hf']
        placeholder = @collection.get "+[fghj567]"
        expect( placeholder.get 'parent_node_ids' ).to.eql ['fghj567']

      it 'disconnects siblings', ->
        @collection.reset [], silent: yes
        @collection.updatePlaceholderNode @node, ['5678jkl', '4522hf']
        placeholder = @collection.get "+[fghj567]"
        expect( placeholder.get 'sibling_node_ids' ).to.eql []

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
      @model = new Backbone.Model id: '8fa451', child_node_ids: []
      @collection.add @model, silent: yes
      @concept1 = new Backbone.Model id: '523345'
      @concept2 = new Backbone.Model id: '4156fe'
      Coreon.Models.Concept.find.withArgs('523345').returns @concept1
      Coreon.Models.Concept.find.withArgs('4156fe').returns @concept2

    it 'updates placeholders before resolving', ->
        done = sinon.spy()
        update = @collection.updateAllPlaceholderNodes = sinon.spy()
        @collection.expand('8fa451').done done
        expect( update ).to.have.been.calledOnce
        expect( update ).to.have.been.calledBefore done


    context 'repository', ->

      beforeEach ->
        @model.set 'type', 'repository', silent: yes

      it 'refetches root node ids', ->
        sinon.spy @collection, 'rootIds'
        @collection.expand '8fa451'
        expect( @collection.rootIds ).to.have.been.calledOnce
        expect( @collection.rootIds ).to.have.been.calledWith yes

      it 'creates nodes from root node ids', ->
        @collection.expand '8fa451'
        @deferred.resolve ['523345', '4156fe']
        node1 = @collection.get '523345'
        expect( node1 ).to.exist
        expect( node1.get 'model' ).to.equal @concept1
        node2 = @collection.get '4156fe'
        expect( node2 ).to.exist
        expect( node2.get 'model' ).to.equal @concept2

      it 'succeeds when all concepts are already loaded', ->
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
