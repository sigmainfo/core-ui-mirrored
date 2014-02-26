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
      expect(selectRepository).to.have.been.calledWith '5272466670686f14a0030000'
      expect(selectRepository).to.have.been.calledBefore action

    it 'routes id to show', ->
      show = sinon.spy()
      router.show = show
      router._bindRoutes()
      path = '5272466670686f14a0030000/concepts/52334519fe4156ec4d0000f4'
      router.navigate path, trigger: yes
      expect(show).to.have.been.calledOnce
      expect(show).to.have.been.calledWith '52334519fe4156ec4d0000f4'

    it 'routes query to search', ->
      search = sinon.spy()
      router.search = search
      router._bindRoutes()
      path = '5272466670686f14a0030000/concepts/search/foo'
      router.navigate path, trigger: yes
      expect(search).to.have.been.calledOnce
      expect(search).to.have.been.calledWith 'foo'

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

    it 'updates selection with current concept', ->
      concept = new Backbone.Model
      find = Coreon.Models.Concept.find
      find.withArgs('my-concept-234', fetch: yes).returns concept
      router.show 'my-concept-234'
      selection = app.get('selection')
      expect(selection).to.be.an.instanceOf Backbone.Collection
      expect(selection).to.have.lengthOf 1
      selected = selection.first()
      expect(selected).to.equal concept

    it 'updates hits with current concept', ->
      concept = new Backbone.Model
      find = Coreon.Models.Concept.find
      find.withArgs('my-concept-234', fetch: yes).returns concept
      router.show 'my-concept-234'
      expect(hits).to.have.lengthOf 1
      hit = hits.first()
      result = hit.get('result')
      expect(result).to.equal concept

    it 'goes into pager mode', ->
      router.show 'my-concept-234'
      scope = app.get('scope')
      expect(scope).to.equal 'pager'

  describe '#search()', ->

    search = null

    beforeEach ->
      sinon.stub Coreon.Models, 'ConceptSearch', ->
        search = fetch: ->

    afterEach ->
      Coreon.Models.ConceptSearch.restore()

    it 'creates search for query', ->
      router.search 'foo'
      expect(Coreon.Models.ConceptsSearch).to.have.been.calledOnce
      expect(Coreon.Models.ConceptsSearch).to.have.been.calledWithNew


  # repo = null
  # search = null
  # collection = null
  # router = null
  #
  # beforeEach ->
  #   repo = new Backbone.Model user_roles: [ "user" ]
  #   search = fetch:->
  #   collection = new Backbone.Collection
  #   collection.reset = sinon.spy()
  #   collection.findByResult = ->
  #   sinon.stub Coreon.Collections.Hits, "collection", -> collection
  #   sinon.stub Coreon.Models, "ConceptSearch", -> search
  #
  #   router = new Coreon.Routers.ConceptsRouter
  #   Backbone.history.start()
  #
  # afterEach ->
  #   Coreon.Collections.Hits.collection.restore()
  #   Coreon.Models.ConceptSearch.restore()
  #   Backbone.history.stop()

  # describe "search()", ->
  #
  #   it "is routed", ->
  #     router.search = sinon.spy()
  #     router._bindRoutes()
  #     router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/search/description/movie", trigger: true
  #     router.search.should.have.been.calledOnce
  #     router.search.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", "description", "movie"
  #
  #   it "is routed with target being optional", ->
  #     router.search = sinon.spy()
  #     router._bindRoutes()
  #     router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/search/movie", trigger: true
  #     router.search.should.have.been.calledOnce
  #     router.search.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", null, "movie"
  #
  #   it "creates search", ->
  #     router.search "c0ffeebabe23c0ffeebabe42", "terms", "gun"
  #     Coreon.Models.ConceptSearch.should.have.been.calledWithNew
  #     Coreon.Models.ConceptSearch.should.have.been.calledWith
  #       query: "gun"
  #       target: "terms"
  #
  # describe "show()", ->
  #
  #   beforeEach ->
  #     sinon.stub Coreon.Models.Concept, "find", ->
  #       concept = new Backbone.Model
  #       concept.sync = sinon.spy()
  #       concept
  #
  #   afterEach ->
  #     Coreon.Models.Concept.find.restore()
  #
  #   it "is routed", ->
  #     router.show = sinon.spy()
  #     router._bindRoutes()
  #     router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/507f191e810c19729de860ea", trigger: true
  #     router.show.should.have.been.calledOnce
  #     router.show.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", "507f191e810c19729de860ea"
  #
  #   it "is not routed for ids not matching the format of a MongoDB ObjectId", ->
  #     router.show = sinon.spy()
  #     router._bindRoutes()
  #     router.navigate "/thisisthewrongformat/concepts/1234", trigger: true
  #     router.show.should.not.have.been.called
  #
  #   it "updates hits", ->
  #     router.show "123"
  #     collection.reset.should.have.been.calledOnce
  #     collection.reset.should.have.been.calledWith [ result: concept ]
  #
  #   it 'updates selection'
  #   it 'updates scope', ->
  #
  #
  # describe "newWithParent()", ->
  #
  #   context "with maintainer privileges", ->
  #
  #     beforeEach ->
  #       repo.set "user_roles", [ "user", "maintainer" ]
  #       sinon.stub Coreon.Helpers, "can", -> true
  #
  #     afterEach ->
  #       Coreon.Helpers.can.restore()
  #       repo.set "user_roles", [ "user" ]
  #
  #     it "is routed", ->
  #       router.newWithParent = sinon.spy()
  #       router._bindRoutes()
  #       router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/new/parent/c0ffeebabe42c0ffeebabe23", trigger: true
  #       router.newWithParent.should.have.been.calledOnce
  #       router.newWithParent.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", "c0ffeebabe42c0ffeebabe23"
  #
  #   context "without maintainer privileges", ->
  #
  #     beforeEach ->
  #       sinon.stub Backbone.history, "navigate"
  #       sinon.stub Coreon.Helpers, "can", -> false
  #
  #     afterEach ->
  #       Coreon.Helpers.can.restore()
  #       Backbone.history.navigate.restore()
  #
  #     it "redirects to start page when not able to create a concept", ->
  #       router.newWithParent()
  #       Backbone.history.navigate.should.have.been.calledOnce
  #       Backbone.history.navigate.should.have.been.calledWith "/"
  #
  #
  # describe "new()", ->
  #
  #   context "with maintainer privileges", ->
  #
  #     beforeEach ->
  #       repo.set "user_roles", [ "user", "maintainer" ]
  #       sinon.stub Coreon.Helpers, "can", -> true
  #
  #     afterEach ->
  #       Coreon.Helpers.can.restore()
  #       repo.set "user_roles", [ "user" ]
  #
  #     it "is routed", ->
  #       router.new = sinon.spy()
  #       router._bindRoutes()
  #       router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/new", trigger: true
  #       router.new.should.have.been.calledOnce
  #
  #     it "is routed with additional params", ->
  #       router.new = sinon.spy()
  #       router._bindRoutes()
  #       router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/new/terms/de/waffe", trigger: true
  #       router.new.should.have.been.calledOnce
  #       router.new.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", "de", "waffe"
  #
  #   context "without maintainer privileges", ->
  #
  #     beforeEach ->
  #       sinon.stub Backbone.history, "navigate"
  #       sinon.stub Coreon.Helpers, "can", -> false
  #
  #     afterEach ->
  #       Coreon.Helpers.can.restore()
  #       Backbone.history.navigate.restore()
  #
  #     it "redirects to start page when not able to create a concept", ->
  #       router.new()
  #       Backbone.history.navigate.should.have.been.calledOnce
  #       Backbone.history.navigate.should.have.been.calledWith "/"
