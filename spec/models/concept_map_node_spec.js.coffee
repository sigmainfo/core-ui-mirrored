#= require spec_helper
#= require models/concept_map_node

describe 'Coreon.Models.ConceptMapNode', ->

  beforeEach ->
    @model = new Coreon.Models.ConceptMapNode

  it 'is a Backbone model', ->
    expect( @model ).to.be.an.instanceOf Coreon.Models.ConceptMapNode

  context 'defaults', ->

    it 'has no model', ->
      expect( @model.get 'model' ).to.be.null

    it 'has a null type', ->
      expect( @model.get 'type' ).to.be.null

    it 'is loaded', ->
      expect( @model.get 'loaded' ).to.be.true

    it 'creates empty set for child_node_ids', ->
      child_node_ids = @model.get 'child_node_ids'
      expect( child_node_ids ).to.be.an.instanceOf Array
      expect( child_node_ids ).to.be.empty
      other = new Coreon.Models.ConceptMapNode
      expect( child_node_ids ).to.not.equal other.get('child_node_ids')

    it 'creates empty set for parent_node_ids', ->
      parent_node_ids = @model.get 'parent_node_ids'
      expect( parent_node_ids ).to.be.an.instanceOf Array
      expect( parent_node_ids ).to.be.empty
      other = new Coreon.Models.ConceptMapNode
      expect( parent_node_ids ).to.not.equal other.get('parent_node_ids')

    it 'is not expanded', ->
      expect( @model.get 'expanded' ).to.be.false

    it 'is not a hit', ->
      expect( @model.get 'hit' ).to.be.false

    it 'is not a parent of hit', ->
      expect( @model.get 'parent_of_hit' ).to.be.false

  describe '#initialize()', ->

    beforeEach ->
      @concept = new Backbone.Model
      @model.set 'model', @concept, silent: yes

    it 'derives id from model', ->
      @concept.id = 'concept-123'
      @model.initialize()
      expect( @model.id ).to.equal 'concept-123'

    it 'derives type from model', ->
      @concept.constructor = name: 'Concept'
      @model.initialize()
      expect( @model.get 'type' ).to.equal 'concept'

    it 'derives hit state from model', ->
      @concept.set 'hit', {score: 1.876, result: @concept}, silent: yes
      @model.initialize()
      expect( @model.get 'hit' ).to.be.true

    it 'updates from model', ->
      spy = sinon.spy()
      @model.update = spy
      @model.initialize()
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledWith @concept

  describe '#update()', ->

    beforeEach ->
      @concept = new Backbone.Model
      @model.set 'model', @concept, silent: yes
      @model.initialize()

    it 'is triggered on model changes', ->
      spy = sinon.spy()
      @model.update = spy
      @model.initialize()
      spy.reset()
      @concept.trigger 'change', @concept
      expect( spy ).to.have.been.calledOnce

    it 'is triggered when model is fully loaded', ->
      spy = sinon.spy()
      @model.update = spy
      @model.initialize()
      spy.reset()
      @concept.trigger 'nonblank', @concept
      expect( spy ).to.have.been.calledOnce

    it 'defers label from model', ->
      @concept.set 'label', 'Billiards', silent: yes
      @model.update @concept
      expect( @model.get 'label' ).to.equal 'Billiards'

    it 'defers label from name when model has no label', ->
      @concept.unset 'label'
      @concept.set 'name', 'Repository', silent: yes
      @model.update @concept
      expect( @model.get 'label' ).to.equal 'Repository'

    it 'defers loaded state from model', ->
      @concept.blank = yes
      @model.update @concept
      expect( @model.get 'loaded' ).to.be.false

    it 'defers parent node ids from superconcept ids', ->
      @concept.set 'superconcept_ids', [ 'abc123', 'fgh789' ]
      @model.update @concept
      expect( @model.get 'parent_node_ids' ).to.eql [ 'abc123', 'fgh789' ]

    it 'leaves parent node ids unchanged when model has no superconcept ids', ->
      @concept.unset 'superconcept_ids'
      @model.update @concept
      expect( @model.get 'parent_node_ids' ).to.eql []

    it 'defers child node ids from subconcept ids', ->
      @concept.set 'subconcept_ids', [ 'abc123', 'fgh789' ]
      @model.update @concept
      expect( @model.get 'child_node_ids' ).to.eql [ 'abc123', 'fgh789' ]

    it 'leaves child node ids unchanged when model has no subconcept ids', ->
      @concept.unset 'subconcept_ids'
      @model.update @concept
      expect( @model.get 'child_node_ids' ).to.eql []

  describe '#path()', ->

    it 'delegates to model', ->
      @concept = new Backbone.Model
      @concept.path = -> '/my-repo/concepts/123'
      @model.set 'model', @concept, silent: yes
      expect( @model.path() ).to.equal '/my-repo/concepts/123'

    it 'defaults to null path without a model', ->
      @model.set 'model', @concept, silent: yes
      expect( @model.path() ).to.equal 'javascript:void(0)'

  describe '#toJSON()', ->

    it 'serializes attributes', ->
      @model.set {
        type: 'repository'
      }, silent: yes
      json = @model.toJSON()
      expect( json ).to.have.property 'type', 'repository'
      expect( json ).to.have.property 'loaded', yes
      expect( json ).to.have.property 'expanded', no
      expect( json ).to.have.property 'hit', no
      expect( json ).to.have.property 'parent_of_hit', no

    it 'skips internal attributes', ->
      json = @model.toJSON()
      expect( json ).to.not.have.property 'model'
      expect( json ).to.not.have.property 'parent_node_ids'
      expect( json ).to.not.have.property 'child_node_ids'

    it 'adds path', ->
      @model.path = -> '/123-repo/concepts/5678'
      json = @model.toJSON()
      expect( json ).to.have.property 'path', '/123-repo/concepts/5678'
