#= require spec_helper
#= require routers/concepts_router

describe 'Coreon.Routers.ConceptsRouter', ->

  hits = null
  app = null
  router = null

  beforeEach ->
    hits = new Backbone.Collection
    sinon.stub Coreon.Collections.Hits, 'collection', -> hits
    app = new Backbone.Model
    app.selectRepository = ->
    router = new Coreon.Routers.ConceptsRouter app

  afterEach ->
    Coreon.Collections.Hits.collection.restore()

  it 'is a Backbone router', ->
    expect(router).to.be.an.instanceOf Backbone.Router

  it 'utilizes #can helper method', ->
    can = router.can
    helper = Coreon.Helpers.can
    expect(can).to.equal helper

  describe '#initialize()', ->

    it 'assigns app', ->
      router.initialize app
      application = router.app
      expect(application).to.equal app

  describe '#_bindRoutes()', ->

    beforeEach ->
      Backbone.history.start silent: yes
      Backbone.history.navigate 'some/other/path'

    afterEach ->
      Backbone.history.stop()

    it 'selects repository before every action', ->
      selectRepository = sinon.spy()
      router.selectRepository = selectRepository
      action = sinon.spy()
      router.action = action
      router.routes = -> 'path': 'action'
      router._bindRoutes()
      path = '5272466670686f14a0030000/concepts/path'
      router.navigate path, trigger: yes
      expect(selectRepository).to.have.been.calledOnce
      expect(selectRepository).to.have.been.calledOn router
      id = '5272466670686f14a0030000'
      expect(selectRepository).to.have.been.calledWith id
      expect(selectRepository).to.have.been.calledBefore action

    it 'routes /:id to #show', ->
      show = sinon.spy()
      router.show = show
      router._bindRoutes()
      path = '5272466670686f14a0030000/concepts/52334519fe4156ec4d0000f4'
      router.navigate path, trigger: yes
      expect(show).to.have.been.calledOnce
      expect(show).to.have.been.calledWith '52334519fe4156ec4d0000f4'

    it 'routes /search/:target/:query to #search', ->
      search = sinon.spy()
      router.search = search
      router._bindRoutes()
      path = '5272466670686f14a0030000/concepts/search/description/foo'
      router.navigate path, trigger: yes
      expect(search).to.have.been.calledOnce
      expect(search).to.have.been.calledWith 'description', 'foo'

    it 'allows skipping search :target', ->
      search = sinon.spy()
      router.search = search
      router._bindRoutes()
      path = '5272466670686f14a0030000/concepts/search/foo'
      router.navigate path, trigger: yes
      expect(search).to.have.been.calledOnce
      expect(search).to.have.been.calledWith null, 'foo'

    it 'routes /new to #new', ->
      action = sinon.spy()
      router.new = action
      router._bindRoutes()
      path = '5272466670686f14a0030000/concepts/new'
      router.navigate path, trigger: yes
      expect(action).to.have.been.calledOnce

    it 'routes /new/broader/:id to #newWithSuper', ->
      newWithSuper = sinon.spy()
      router.newWithSuper = newWithSuper
      router._bindRoutes()
      base = '5272466670686f14a0030000/concepts'
      path = "#{base}/new/broader/52334519fe4156ec4d0000f4"
      router.navigate path, trigger: yes
      expect(newWithSuper).to.have.been.calledOnce
      expect(newWithSuper).to.have.been.calledWith '52334519fe4156ec4d0000f4'

    it 'routes /new/terms/:lang/:value to #newWithTerm', ->
      newWithTerm = sinon.spy()
      router.newWithTerm = newWithTerm
      router._bindRoutes()
      base = '5272466670686f14a0030000/concepts'
      path = "#{base}/new/terms/en/gun"
      router.navigate path, trigger: yes
      expect(newWithTerm).to.have.been.calledOnce
      expect(newWithTerm).to.have.been.calledWith 'en', 'gun'

  describe '#selectRepository()', ->

    it 'delegates call to application', ->
      selectRepository = sinon.spy()
      app.selectRepository = selectRepository
      router.selectRepository('my-repo-345')
      expect(selectRepository).to.have.been.calledOnce
      expect(selectRepository).to.have.been.calledWith 'my-repo-345'

  describe '#show()', ->

    beforeEach ->
      sinon.stub Coreon.Models.Concept, 'find'

    afterEach ->
      Coreon.Models.Concept.find.restore()

    it 'updates selection', ->
      concept = new Backbone.Model
      find = Coreon.Models.Concept.find
      find.withArgs('my-concept-234', fetch: yes).returns concept
      router.show 'my-concept-234'
      selection = app.get('selection')
      expect(selection).to.be.an.instanceOf Backbone.Collection
      expect(selection).to.have.lengthOf 1
      selected = selection.first()
      expect(selected).to.equal concept

    it 'updates hits', ->
      concept = new Backbone.Model
      find = Coreon.Models.Concept.find
      find.withArgs('my-concept-234', fetch: yes).returns concept
      router.show 'my-concept-234'
      expect(hits).to.have.lengthOf 1
      hit = hits.first()
      result = hit.get('result')
      expect(result).to.equal concept

    it 'goes into pager mode', ->
      app.set 'scope', 'index', silent: yes
      router.show 'my-concept-234'
      scope = app.get('scope')
      expect(scope).to.equal 'pager'

  describe '#search()', ->

    search = null
    request = null

    beforeEach ->
      request = $.Deferred()
      sinon.stub Coreon.Models, 'ConceptSearch', ->
        search = fetch: sinon.spy(request.promise)

    afterEach ->
      Coreon.Models.ConceptSearch.restore()

    it 'updates query on application', ->
      router.search null, 'foo'
      query = app.get('query')
      expect(query).to.equal 'foo'

    it 'unescapes query string', ->
      router.search null, 'M%C3%A4rchen'
      query = app.get('query')
      expect(query).to.equal 'Märchen'

    it 'creates search from query', ->
      router.search 'description', 'foo'
      constructor = Coreon.Models.ConceptSearch
      expect(constructor).to.have.been.calledOnce
      expect(constructor).to.have.been.calledWithNew
      expect(constructor).to.have.been.calledWith
        query: 'foo'
        target: 'description'

    it 'creates search from unescaped query', ->
      router.search null, 'M%C3%A4rchen'
      constructor = Coreon.Models.ConceptSearch
      expect(constructor).to.have.been.calledWith
        query: 'Märchen'
        target: null

    it 'triggers search', ->
      router.search null, 'foo'
      fetch = search.fetch
      expect(fetch).to.have.been.calledOnce

    it 'updates selection when done', ->
      app.set 'selection', null, silent: yes
      hits.reset [
        { result: id: 'hit-1' }
        { result: id: 'hit-2' }
        { result: id: 'hit-3' }
      ], silent: yes
      router.search null, 'foo'
      request.resolve()
      selection = app.get('selection')
      expect(selection).to.be.an.instanceOf Backbone.Collection
      ids = selection.pluck('id')
      expect(ids).to.eql ['hit-1', 'hit-2', 'hit-3']

    it 'updates scope when done', ->
      app.set 'scope', 'pager', silent: yes
      router.search null, 'foo'
      request.resolve()
      scope = app.get('scope')
      expect(scope).to.equal 'index'

  describe '#new()', ->

    can = null

    beforeEach ->
      can = sinon.stub()
      can.returns false
      router.can = can

    context 'without privileges', ->

      beforeEach ->
        can.withArgs('create', Coreon.Models.Concept).returns false

      it 'is redirected to repository root page', ->
        app.set 'repository', {id: '5272466670686f14a0030000'}, silent: yes
        navigate = sinon.spy()
        router.navigate = navigate
        router.new()
        expect(navigate).to.have.been.calledOnce
        expect(navigate).to.have.been.calledWith '5272466670686f14a0030000'
                                               , trigger: yes
                                               , replace: yes

    context 'with privileges', ->

      concept = null

      beforeEach ->
        sinon.stub Coreon.Models, 'Concept', ->
          concept = new Backbone.Model arguments...
        can.withArgs('create', Coreon.Models.Concept).returns true

      afterEach ->
        Coreon.Models.Concept.restore()

      it 'creates new concept', ->
        router.new()
        constructor = Coreon.Models.Concept
        expect(constructor).to.have.been.calledOnce
        expect(constructor).to.have.been.calledWithNew

      it 'sets attrs on newly created concept', ->
        router.new superconcept_ids: ['superconcept-123']
        ids = concept.get('superconcept_ids')
        expect(ids).to.eql ['superconcept-123']

      it 'updates selection', ->
        router.new()
        selection = app.get('selection')
        expect(selection).to.be.an.instanceOf Backbone.Collection
        expect(selection).to.have.lengthOf 1
        selected = selection.first()
        expect(selected).to.equal concept

      it 'updates hits', ->
        router.new()
        expect(hits).to.have.lengthOf 1
        hit = hits.first()
        result = hit.get('result')
        expect(result).to.equal concept

      it 'goes into pager mode', ->
        app.set 'scope', 'index', silent: yes
        router.new()
        scope = app.get('scope')
        expect(scope).to.equal 'pager'

  describe '#newWithSuper()', ->

    create = null

    beforeEach ->
      create = sinon.spy()
      router.new = create

    it 'delegates to #new passing superconcept id', ->
      router.newWithSuper 'super-345'
      expect(create).to.have.been.calledOnce
      expect(create).to.have.been.calledWith superconcept_ids: ['super-345']

  describe '#newWithTerm()', ->

    create = null

    beforeEach ->
      create = sinon.spy()
      router.new = create

    it 'delegates to #new passing term attrs', ->
      router.newWithTerm 'en', 'gun'
      expect(create).to.have.been.calledOnce
      expect(create).to.have.been.calledWith terms: [lang: 'en', value: 'gun']

    it 'unescapes term value', ->
      router.newWithTerm 'de', 'M%C3%A4rchen'
      value = create.firstCall.args[0].terms[0].value
      expect(value).to.equal 'Märchen'
