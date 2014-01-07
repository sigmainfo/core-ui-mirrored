#= require spec_helper
#= require models/term_list

describe 'Coreon.Models.TermList', ->

  beforeEach ->
    @repositorySettings = new Backbone.Model
    Coreon.application =
      repositorySettings: => @repositorySettings
      sourceLang: -> null
      graphUri: -> 'coreon.api'
    @model = new Coreon.Models.TermList

  afterEach ->
    delete Coreon.application
    @model.stopListening()

  it 'is a Backbone model', ->
    expect( @model ).to.be.an.instanceof Backbone.Model

  describe '#defaults()', ->

    it 'has no source lang', ->
      expect( @model.get 'source' ).to.be.null

    it 'has no target lang', ->
      expect( @model.get 'target' ).to.be.null

    it 'has limited scope', ->
      expect( @model.get 'scope' ).to.equal 'hits'

    it 'is not loading next', ->
      expect( @model.get 'loadingNext' ).to.be.false

  describe '#initialize()', ->

    it 'creates empty terms collection', ->
      collection = @model.terms
      expect( collection ).to.exist
      expect( collection ).to.be.an.instanceOf Coreon.Collections.Terms
      expect( collection.models ).to.be.empty

    it 'sets source lang', ->
      Coreon.application.sourceLang = -> 'fr'
      @model.initialize()
      expect( @model.get 'source' ).to.equal 'fr'

    it 'assigns reference to term hits', ->
      hits = new Backbone.Collection
      sinon.stub Coreon.Collections.Terms, 'hits', -> hits
      try
        @model.initialize()
        expect( @model.hits ).to.equal hits
      finally
        Coreon.Collections.Terms.hits.restore()

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
      @model.trigger 'change:scope'
      expect( @model.update ).to.have.been.calledOnce
      expect( @model.update ).to.have.been.calledOn @model

    it 'triggers update event', ->
      spy = sinon.spy()
      @model.on 'update', spy
      @model.terms.reset = sinon.spy()
      @model.update()
      expect( spy ).to.have.been.calledOnce
      expect( @model.terms.reset ).to.have.been.calledOnce
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
          @model.hits.lang = sinon.stub()
          @model.set 'scope', 'hits', silent: yes

        it 'fills collection with terms from source lang', ->
          @model.hits.lang.withArgs('de').returns [ lang: 'de', value: 'Schuh' ]
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
          collection.fetch = sinon.stub()
          collection.fetch.returns done: ->
          @model.set 'scope', 'all', silent: yes

        it 'clears collection', ->
          @model.terms.reset [ lang: 'de', val: 'Schuh' ], silent: yes
          @model.update()
          collection = @model.terms
          expect( collection.models ).to.be.empty

        it 'fetches terms in source lang', ->
          @model.update()
          collection = @model.terms
          expect( collection.fetch ).to.have.been.calledOnce
          expect( collection.fetch ).to.have.been.calledWith 'de'

        it 'triggers update on response', ->
          collection = @model.terms
          deferred = $.Deferred()
          collection.fetch = -> deferred.promise()
          spy = sinon.spy()
          @model.on 'update', spy
          @model.update()
          spy.reset()
          deferred.resolve []
          expect( spy ).to.have.been.calledOnce

  describe '#updateSource()', ->

    beforeEach ->
      @model.update = sinon.spy()

    it 'is triggered on source lang change', ->
      @model.updateSource = sinon.spy()
      @model.initialize()
      @model.updateSource.reset()
      @repositorySettings.trigger 'change:sourceLanguage'
      expect( @model.updateSource ).to.have.been.calledOnce
      expect( @model.updateSource ).to.have.been.calledOn @model

    it 'updates source lang', ->
      @model.set 'source', 'de', silent: yes
      Coreon.application.sourceLang = -> 'fr'
      @model.updateSource()
      expect( @model.get 'source' ).to.equal 'fr'

  describe '#onRoute()', ->

    it 'is triggered when history routes', ->
      @model.onRoute = sinon.spy()
      @model.initialize()
      Backbone.history.trigger new Backbone.Router
                             , 'show'
                             , [ '1234567' ]
      expect( @model.onRoute ).to.have.been.calledOnce
      expect( @model.onRoute ).to.have.been.calledOn @model


    it 'widens scope when routed to repository root', ->
      @model.set 'scope', 'hits', silent: yes
      @model.onRoute new Coreon.Routers.RepositoriesRouter
                   , 'show'
                   , [ '1234567' ]
      expect( @model.get 'scope' ).to.equal 'all'

    it 'forces update', ->
      @model.set 'scope', 'all', silent: yes
      @model.update = sinon.spy()
      @model.initialize()
      @model.onRoute new Coreon.Routers.RepositoriesRouter
                   , 'show'
                   , [ '1234567' ]
      expect( @model.update ).to.have.been.calledOnce
      expect( @model.update ).to.have.been.calledOn @model

    it 'does not trigger double update', ->
      @model.set 'scope', 'hits', silent: yes
      @model.update = sinon.spy()
      @model.initialize()
      @model.onRoute new Coreon.Routers.RepositoriesRouter
                   , 'show'
                   , [ '1234567' ]
      expect( @model.update ).to.have.been.calledOnce
      expect( @model.update ).to.have.been.calledOn @model

  describe '#onHitsReset()', ->

    it 'is triggered when hits are reset', ->
      @model.onHitsReset = sinon.spy()
      @model.initialize()
      @model.hits.trigger 'reset'
      expect( @model.onHitsReset ).to.have.been.calledOnce
      expect( @model.onHitsReset ).to.have.been.calledOn @model

    it 'focuses on hits', ->
      @model.set 'scope', 'all', silent: yes
      @model.onHitsReset()
      expect( @model.get 'scope' ).to.equal 'hits'

    it 'forces update', ->
      @model.set 'scope', 'hits', silent: yes
      @model.update = sinon.spy()
      @model.initialize()
      @model.onHitsReset()
      expect( @model.update ).to.have.been.calledOnce
      expect( @model.update ).to.have.been.calledOn @model

    it 'does not trigger double update', ->
      @model.set 'scope', 'all', silent: yes
      @model.update = sinon.spy()
      @model.initialize()
      @model.onHitsReset()
      expect( @model.update ).to.have.been.calledOnce
      expect( @model.update ).to.have.been.calledOn @model

  describe '#next()', ->

    beforeEach ->
      @model.terms.fetch = sinon.spy =>
        @request = $.Deferred()
        @request.promise()

    context 'does not have next', ->

      beforeEach ->
        @model.hasNext = -> no

      it 'returns resolved promise', ->
        promise = @model.next()
        expect( promise.state() ).to.equal 'resolved'

      it 'resolves callbacks with empty set', ->
        done = sinon.spy()
        @model.next().then done
        expect( done ).to.have.been.calledOnce
        expect( done ).to.have.been.calledWith []

    context 'has next', ->

      beforeEach ->
        @model.hasNext = -> yes

      it 'fetches terms after last one', ->
        @model.set 'source', 'de', silent: yes
        @model.terms.reset [
          { id: 'a-term'            }
          { id: 'another-term'      }
          { id: 'last-term-in-list' }
        ], silent: yes
        @model.next()
        fetch = @model.terms.fetch
        expect( fetch ).to.have.been.calledOnce
        expect( fetch ).to.have.been.calledWith 'de', from: 'last-term-in-list'

      it 'fetches first batch when empty', ->
        @model.set 'source', 'de', silent: yes
        @model.terms.reset [], silent: yes
        @model.next()
        fetch = @model.terms.fetch
        expect( fetch ).to.have.been.calledOnce
        expect( fetch ).to.have.been.calledWith 'de', {}

      it 'returns promise from fetch', ->
        promise = @model.next()
        expect( promise ).to.equal @request.promise()

  describe '#hasNext()', ->

    context 'scope narrowed down to hits', ->

      beforeEach ->
        @model.set 'scope', 'hits', silent: yes

      it 'is false', ->
        expect( @model.hasNext() ).to.be.false

    context 'wide scope', ->

      beforeEach ->
        @model.set 'scope', 'all', silent: yes

      context 'no source selected', ->

        beforeEach ->
          @model.set 'source', null, silent: yes
          @model.update()

        it 'is false', ->
          expect( @model.hasNext() ).to.be.false

      context 'with selected source', ->

        beforeEach ->
          @model.set 'source', 'de', silent: yes
          @model.terms.fetch = =>
            @request = $.Deferred()
            @request.promise()
          @model.update()

        it 'is true by default', ->
          expect( @model.hasNext() ).to.be.true

        it 'is false after last fetch', ->
          @request.resolve [ id: 'last-term' ]
          expect( @model.hasNext() ).to.be.false

