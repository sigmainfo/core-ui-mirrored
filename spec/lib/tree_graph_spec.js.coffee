#= require spec_helper
#= require lib/tree_graph

describe 'Coreon.Lib.TreeGraph', ->

  beforeEach ->
    @graph = new Coreon.Lib.TreeGraph []

  describe '#constructor()', ->

    it 'assigns models', ->
      models = []
      graph = new Coreon.Lib.TreeGraph models
      expect( graph ).to.have.property 'models', models

  describe '#generate()', ->

    it 'returns tree data structure', ->
      @graph.models = [
        new Backbone.Model id: '787acf6', parent_node_ids: []
      ]
      tree = @graph.generate()
      expect( tree ).to.have.property 'tree', @graph.root
      expect( tree ).to.have.property 'edges', @graph.edges

    context 'root', ->

      it 'identifies root', ->
        repository = new Backbone.Model id: '787acf6', parent_node_ids: []
        rootNode = id: '787acf6'
        repository.toJSON = -> rootNode
        @graph.models = [ repository ]
        @graph.generate()
        expect( @graph ).to.have.property 'root', rootNode

      it 'nullifies root when models are empty', ->
        @graph.models = []
        @graph.generate()
        expect( @graph ).to.have.property 'root', null

    context 'children', ->

      it 'connects top level nodes to root', ->
        @graph.models = [
          new Backbone.Model id: '515fe41', parent_node_ids: []
          new Backbone.Model id: '4287g7h', parent_node_ids: []
        ]
        @graph.generate()
        expect( @graph.root ).to.have.property('children').with.lengthOf 1
        expect( @graph.root.children[0] ).to.have.property 'id', '4287g7h'

      it 'creates empty children for leaf nodes', ->
        @graph.models = [
          new Backbone.Model id: '515fe41', parent_node_ids: []
          new Backbone.Model id: '4287g7h', parent_node_ids: []
        ]
        @graph.generate()
        node = @graph.root.children[0]
        expect( node ).to.have.property('children').that.is.empty

      it 'connects related nodes', ->
        @graph.models = [
          new Backbone.Model id: '4287g7h', parent_node_ids: []
          new Backbone.Model id: '515fe41', parent_node_ids: []
          new Backbone.Model id: '787acf6', parent_node_ids: ['515fe41']
        ]
        @graph.generate()
        node = @graph.root.children[0]
        expect( node.children ).to.have.lengthOf 1
        expect( node.children[0] ).to.have.property 'id', '787acf6'

      it 'keeps longest path only for multiparented nodes', ->
        @graph.models = [
          new Backbone.Model id: '4287g7h', parent_node_ids: []
          new Backbone.Model id: '515fe41', parent_node_ids: []
          new Backbone.Model id: '787acf6', parent_node_ids: ['515fe41']
          new Backbone.Model id: '16fjk23', parent_node_ids: ['515fe41', '787acf6']
        ]
        @graph.generate()
        parent = @graph.root.children[0]
        expect( parent.children ).to.have.lengthOf 1
        expect( parent.children[0] ).to.have.property 'id', '787acf6'
        child = parent.children[0]
        expect( child.children ).to.have.lengthOf 1
        expect( child.children[0] ).to.have.property 'id', '16fjk23'

    context 'edges', ->

      it 'creates empty set when models are empty', ->
        @graph.models = []
        @graph.generate()
        expect( @graph.edges ).to.be.an.instanceOf(Array).that.is.empty

      it 'creates edges for top level nodes', ->
        @graph.models = [
          new Backbone.Model id: '515fe41', parent_node_ids: []
          new Backbone.Model id: '787acf6', parent_node_ids: []
        ]
        @graph.generate()
        expect( @graph.edges ).to.have.lengthOf 1
        expect( @graph.edges[0] ).to.have.deep.property 'source.id', '515fe41'
        expect( @graph.edges[0] ).to.have.deep.property 'target.id', '787acf6'

      it 'creates edges for concept connections', ->
        @graph.models = [
          new Backbone.Model id: '4287g7h', parent_node_ids: []
          new Backbone.Model id: '515fe41', parent_node_ids: []
          new Backbone.Model id: '787acf6', parent_node_ids: ['515fe41']
        ]
        @graph.generate()
        edge = edge for edge in @graph.edges when edge.source.id is '515fe41'
        expect( edge ).to.exist
        expect( edge ).to.have.deep.property 'target.id', '787acf6'
