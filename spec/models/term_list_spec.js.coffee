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

    it 'is not loading prev', ->
      expect( @model.get 'loadingPrev' ).to.be.false

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

  describe '#reset()', ->

    it 'is triggered on source change', ->
      @model.reset = sinon.spy()
      @model.initialize()
      @model.set 'source', 'hu'
      expect( @model.reset ).to.have.been.calledOnce
      expect( @model.reset ).to.have.been.calledOn @model

    it 'is triggered on scope change', ->
      @model.reset = sinon.spy()
      @model.initialize()
      @model.trigger 'change:scope'
      expect( @model.reset ).to.have.been.calledOnce
      expect( @model.reset ).to.have.been.calledOn @model

    it 'triggers reset event', ->
      spy = sinon.spy()
      @model.on 'reset', spy
      @model.terms.reset = sinon.spy()
      @model.reset()
      expect( spy ).to.have.been.calledOnce
      expect( @model.terms.reset ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledAfter @model.terms.reset

    context 'no source lang selected', ->

      beforeEach ->
        @model.set 'source', null, silent: yes

      it 'clears collection', ->
        @model.terms.reset [ lang: 'de', val: 'Schuh' ], silent: yes
        @model.reset()
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
          @model.reset()
          collection = @model.terms
          expect( collection ).to.have.lengthOf 1
          expect( collection.at(0).get 'value' ).to.equal 'Schuh'

        it 'does not fetch terms', ->
          collection = @model.terms
          collection.fetch = sinon.spy()
          @model.reset()
          expect( collection.fetch ).to.not.have.been.called

      context 'with universal scope', ->

        beforeEach ->
          @model.set 'scope', 'all', silent: yes
          @model.terms.fetch = =>
            @deferred = $.Deferred()
            @deferred.promise()

        it 'clears collection', ->
          @model.terms.reset [ lang: 'de', val: 'Schuh' ], silent: yes
          @model.reset()
          collection = @model.terms
          expect( collection.models ).to.be.empty

        it 'fetches first batch', ->
          @model.next = sinon.spy()
          @model.reset()
          expect( @model.next ).to.have.been.calledOnce

        it 'triggers event on response', ->
          spy = sinon.spy()
          @model.on 'append', spy
          @model.reset()
          spy.reset()
          terms = []
          @deferred.resolve terms
          expect( spy ).to.have.been.calledOnce
          expect( spy ).to.have.been.calledWith terms

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
      @model.reset = sinon.spy()
      @model.initialize()
      @model.onRoute new Coreon.Routers.RepositoriesRouter
                   , 'show'
                   , [ '1234567' ]
      expect( @model.reset ).to.have.been.calledOnce
      expect( @model.reset ).to.have.been.calledOn @model

    it 'does not trigger double update', ->
      @model.set 'scope', 'hits', silent: yes
      @model.reset = sinon.spy()
      @model.initialize()
      @model.onRoute new Coreon.Routers.RepositoriesRouter
                   , 'show'
                   , [ '1234567' ]
      expect( @model.reset ).to.have.been.calledOnce
      expect( @model.reset ).to.have.been.calledOn @model

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
      @model.reset = sinon.spy()
      @model.initialize()
      @model.onHitsReset()
      expect( @model.reset ).to.have.been.calledOnce
      expect( @model.reset ).to.have.been.calledOn @model

    it 'does not trigger double update', ->
      @model.set 'scope', 'all', silent: yes
      @model.reset = sinon.spy()
      @model.initialize()
      @model.onHitsReset()
      expect( @model.reset ).to.have.been.calledOnce
      expect( @model.reset ).to.have.been.calledOn @model

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

      it 'fetches terms after last one by default', ->
        @model.set 'source', 'de', silent: yes
        @model.terms.reset [
          { id: 'a-term'            }
          { id: 'another-term'      }
          { id: 'last-term-in-list' }
        ], silent: yes
        @model.next()
        fetch = @model.terms.fetch
        expect( fetch ).to.have.been.calledOnce
        expect( fetch ).to.have.been.calledWith 'de'
                                              , from   : 'last-term-in-list'
                                              , order  : 'asc'
                                              , remove : no

      it 'fetches terms after given id', ->
        @model.set 'source', 'de', silent: yes
        @model.next 'my-term-123'
        fetch = @model.terms.fetch
        expect( fetch ).to.have.been.calledOnce
        expect( fetch ).to.have.been.calledWith 'de'
                                              , from   : 'my-term-123'
                                              , order  : 'asc'
                                              , remove : no

      it 'fetches first batch when empty', ->
        @model.set 'source', 'de', silent: yes
        @model.terms.reset [], silent: yes
        @model.next()
        fetch = @model.terms.fetch
        expect( fetch ).to.have.been.calledOnce
        expect( fetch ).to.have.been.calledWith 'de'
                                              , order  : 'asc'
                                              , remove : no

      it 'returns promise from fetch', ->
        promise = @model.next()
        expect( promise ).to.equal @request.promise()

      it 'updates loading state', ->
        @model.next()
        expect( @model.get 'loadingNext' ).to.be.true

      it 'resolves loading state on success', ->
        @model.next()
        @request.resolve []
        expect( @model.get 'loadingNext' ).to.be.false

      it 'resolves loading state on error', ->
        @model.next()
        @request.reject()
        expect( @model.get 'loadingNext' ).to.be.false

      it 'triggers event on response', ->
        spy = sinon.spy()
        @model.on 'append', spy
        @model.next()
        spy.reset()
        @request.resolve []
        expect( spy ).to.have.been.calledOnce

      it 'passes appended terms along when triggering event', ->
        @model.terms.reset [], silent: yes
        spy = sinon.spy()
        @model.on 'append', spy
        @model.next 'term-456'
        spy.reset()
        response = [
          { id: 'term-456' }
          { id: 'term-789' }
          { id: 'term-0ab' }
        ]
        @model.terms.add response
        @request.resolve response
        expect( spy ).to.have.been.calledOnce
        terms = spy.firstCall.args[0]
        term_ids = terms.map ( t ) -> id: t.id
        expect( term_ids ).to.eql [
          { id: 'term-456' }
          { id: 'term-789' }
          { id: 'term-0ab' }
        ]

      it 'excludes from-term when it was present before', ->
        @model.terms.reset [
          { id: 'term-123' }
          { id: 'term-456' }
        ], silent: yes
        spy = sinon.spy()
        @model.on 'append', spy
        @model.next 'term-456'
        spy.reset()
        response = [
          { id: 'term-456' }
          { id: 'term-789' }
          { id: 'term-0ab' }
        ]
        @model.terms.add response
        @request.resolve response
        terms = spy.firstCall.args[0]
        term_ids = terms.map ( t ) -> id: t.id
        expect( term_ids ).to.eql [
          { id: 'term-789' }
          { id: 'term-0ab' }
        ]

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
          @model.reset()

        it 'is false', ->
          expect( @model.hasNext() ).to.be.false

      context 'with selected source', ->

        beforeEach ->
          @model.set 'source', 'de', silent: yes
          @model.terms.fetch = =>
            @request = $.Deferred()
            @request.promise()
          @model.reset()

        it 'is true by default', ->
          expect( @model.hasNext() ).to.be.true

        it 'is false after last fetch', ->
          @model.next()
          @request.resolve [ id: 'last-term' ]
          expect( @model.hasNext() ).to.be.false

  describe '#prev()', ->

    beforeEach ->
      @model.terms.fetch = sinon.spy =>
        @request = $.Deferred()
        @request.promise()

    context 'does not have prev', ->

      beforeEach ->
        @model.hasPrev = -> no

      it 'returns resolved promise', ->
        promise = @model.prev()
        expect( promise.state() ).to.equal 'resolved'

      it 'resolves callbacks with empty set', ->
        done = sinon.spy()
        @model.prev().then done
        expect( done ).to.have.been.calledOnce
        expect( done ).to.have.been.calledWith []

    context 'has prev', ->

      beforeEach ->
        @model.hasPrev = -> yes

      it 'fetches terms before first one by default', ->
        @model.set 'source', 'de', silent: yes
        @model.terms.reset [
          { id: 'aaa-first-term-in-list' }
          { id: 'a-term'                 }
          { id: 'another-term'           }
        ], silent: yes
        @model.prev()
        fetch = @model.terms.fetch
        expect( fetch ).to.have.been.calledOnce
        expect( fetch ).to.have.been.calledWith 'de'
                                              , from   : 'aaa-first-term-in-list'
                                              , order  : 'desc'
                                              , remove : no

      it 'fetches terms before given id', ->
        @model.set 'source', 'de', silent: yes
        @model.prev 'my-term-123'
        fetch = @model.terms.fetch
        expect( fetch ).to.have.been.calledOnce
        expect( fetch ).to.have.been.calledWith 'de'
                                              , from   : 'my-term-123'
                                              , order  : 'desc'
                                              , remove : no

      it 'fetches last batch when empty', ->
        @model.set 'source', 'de', silent: yes
        @model.terms.reset [], silent: yes
        @model.prev()
        fetch = @model.terms.fetch
        expect( fetch ).to.have.been.calledOnce
        expect( fetch ).to.have.been.calledWith 'de'
                                              , order  : 'desc'
                                              , remove : no

      it 'returns promise from fetch', ->
        promise = @model.prev()
        expect( promise ).to.equal @request.promise()

      it 'updates loading state', ->
        @model.prev()
        expect( @model.get 'loadingPrev' ).to.be.true

      it 'resolves loading state on success', ->
        @model.prev()
        @request.resolve []
        expect( @model.get 'loadingPrev' ).to.be.false

      it 'resolves loading state on error', ->
        @model.prev()
        @request.reject()
        expect( @model.get 'loadingPrev' ).to.be.false

      it 'triggers event on response', ->
        spy = sinon.spy()
        @model.on 'prepend', spy
        @model.prev()
        spy.reset()
        @request.resolve []
        expect( spy ).to.have.been.calledOnce

      it 'passes prepended terms along when triggering event', ->
        @model.terms.comparator = ( t ) -> t.id
        @model.terms.reset [], silent: yes
        spy = sinon.spy()
        @model.on 'prepend', spy
        @model.prev 'term-456'
        spy.reset()
        response = [
          { id: 'term-456' }
          { id: 'term-123' }
          { id: 'term-000' }
        ]
        @model.terms.add response
        @request.resolve response
        expect( spy ).to.have.been.calledOnce
        terms = spy.firstCall.args[0]
        term_ids = terms.map ( t ) -> id: t.id
        expect( term_ids ).to.eql [
          { id: 'term-000' }
          { id: 'term-123' }
          { id: 'term-456' }
        ]

      it 'excludes from-term when it was present before', ->
        @model.terms.comparator = ( t ) -> t.id
        @model.terms.reset [
          { id: 'term-456' }
          { id: 'term-9ab' }
        ], silent: yes
        spy = sinon.spy()
        @model.on 'prepend', spy
        @model.prev 'term-456'
        spy.reset()
        response = [
          { id: 'term-456' }
          { id: 'term-123' }
          { id: 'term-000' }
        ]
        @model.terms.add response
        @request.resolve response
        terms = spy.firstCall.args[0]
        term_ids = terms.map ( t ) -> id: t.id
        expect( term_ids ).to.eql [
          { id: 'term-000' }
          { id: 'term-123' }
        ]

  describe '#hasPrev()', ->

    context 'scope narrowed down to hits', ->

      beforeEach ->
        @model.set 'scope', 'hits', silent: yes

      it 'is false', ->
        expect( @model.hasPrev() ).to.be.false

    context 'wide scope', ->

      beforeEach ->
        @model.set 'scope', 'all', silent: yes

      context 'no source selected', ->

        beforeEach ->
          @model.set 'source', null, silent: yes
          @model.reset()

        it 'is false', ->
          expect( @model.hasPrev() ).to.be.false

      context 'with selected source', ->

        beforeEach ->
          @model.set 'source', 'de', silent: yes
          @model.terms.fetch = =>
            @request = $.Deferred()
            @request.promise()
          @model.reset()

        it 'is true by default', ->
          expect( @model.hasPrev() ).to.be.true

        it 'is false after last fetch', ->
          @model.prev()
          @request.resolve [ id: 'first-term' ]
          expect( @model.hasPrev() ).to.be.false

  describe '#clearTerms()', ->

    it 'resets terms', ->
      @model.terms.reset [ lang: 'de', value: 'Koffer' ], silent: yes
      @model.clearTerms()
      expect( @model.terms ).to.have.lengthOf 0

    it 'clears loading state for tail', ->
      @model.terms.fetch = =>
        @request = $.Deferred()
        @request.promise()
      @model.set
        source: 'de'
        scope: 'all'
      , silent: yes
      @model.fetch 'de'
      @request.resolve []
      @model.clearTerms()
      expect( @model.hasNext() ).to.be.true

    it 'triggers reset event', ->
      spy = sinon.spy()
      @model.on 'reset', spy
      @model.terms.reset = sinon.spy()
      @model.clearTerms()
      expect( spy ).to.have.been.calledOnce
      expect( @model.terms.reset ).to.have.been.calledOnce
      expect( spy ).to.have.been.calledAfter @model.terms.reset
      expect( spy ).to.have.been.calledWith @model.terms, @model.attributes

    it 'can be silenced', ->
      spy = sinon.spy()
      @model.on 'reset', spy
      @model.clearTerms silent: yes
      expect( spy ).to.not.have.been.called
