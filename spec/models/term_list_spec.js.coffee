#= require spec_helper
#= require models/term_list

describe 'Coreon.Models.TermList', ->

  beforeEach ->
    @model = new Coreon.Models.TermList

  it 'is a Backbone model', ->
    expect( @model ).to.be.an.instanceof Backbone.Model

  describe '#defaults()', ->

    it 'has no source lang', ->
      expect( @model.get 'source' ).to.be.null

    it 'has no target lang', ->
      expect( @model.get 'target' ).to.be.null

    it 'has limited scope', ->
      expect( @model.get 'scope' ).to.equal 'hits'

  describe '#initialize()', ->

    it 'creates empty terms collection', ->
      collection = @model.terms
      expect( collection ).to.exist
      expect( collection ).to.be.an.instanceOf Coreon.Collections.Terms
      expect( collection.models ).to.be.empty

  describe '#update()', ->

    it 'is triggered on source change', ->
      @model.update = sinon.spy()
      @model.initialize()
      @model.set 'source', 'hu'
      expect( @model.update ).to.have.been.calledOnce
      expect( @model.update ).to.have.been.calledOn @model

    it 'is triggered on scope change', ->
      @model.update = sinon.spy()
      @model.initialize()
      @model.set 'scope', 'all'
      expect( @model.update ).to.have.been.calledOnce
      expect( @model.update ).to.have.been.calledOn @model

    it 'triggers update event', ->
      spy = sinon.spy()
      @model.terms.reset = sinon.spy()
      @model.on 'update', spy
      @model.update()
      expect( spy ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledAfter @model.terms.reset

    context 'no source lang selected', ->

      beforeEach ->
        @model.set 'source', null, silent: yes

      it 'clears collection', ->
        @model.terms.reset [ lang: 'de', val: 'Schuh' ], silent: yes
        @model.update()
        collection = @model.terms
        expect( collection.models ).to.be.empty

    context 'with source lang', ->

      beforeEach ->
        @model.set 'source', 'de', silent: yes

      context 'with scope narrowed down to hits', ->

        beforeEach ->
          @hits = new Backbone.Collection
          @hits.lang = sinon.stub()
          Coreon.Collections.Terms.hits = => @hits
          @model.set 'scope', 'hits', silent: yes

        it 'fills collection with terms from source lang', ->
          @hits.lang.withArgs('de').returns [ lang: 'de', value: 'Schuh' ]
          @model.update()
          collection = @model.terms
          expect( collection ).to.have.lengthOf 1
          expect( collection.at(0).get 'value' ).to.equal 'Schuh'

        it 'does not fetch terms', ->
          collection = @model.terms
          collection.fetch = sinon.spy()
          @model.update()
          expect( collection.fetch ).to.not.have.been.called

      context 'with universal scope', ->

        beforeEach ->
          collection = @model.terms
          collection.fetch = sinon.spy()
          @model.set 'scope', 'all', silent: yes

        it 'clears collection', ->
          @model.terms.reset [ lang: 'de', val: 'Schuh' ], silent: yes
          @model.update()
          collection = @model.terms
          expect( collection.models ).to.be.empty

        it 'fetches terms in source lang', ->
          collection = @model.terms
          @model.update()
          expect( collection.fetch ).to.have.been.calledOnce
          expect( collection.fetch ).to.have.been.calledWith 'de'
