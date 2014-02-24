#= require spec_helper
#= require routers/concepts_router
#= require config/application

describe 'Coreon.Routers.ConceptsRouter', ->

  beforeEach ->
    @repo = new Backbone.Model user_roles: [ "user" ]
    @search = fetch:->
    @collection = new Backbone.Collection
    @collection.reset = sinon.spy()
    @collection.findByResult = ->
    sinon.stub Coreon.Collections.Hits, "collection", => @collection
    sinon.stub Coreon.Models, "ConceptSearch", => @search

    @view =
      repository:=> @repo
      query:->
      switch:->

    @router = new Coreon.Routers.ConceptsRouter @view
    Backbone.history.start(silent:true)

  afterEach ->
    Coreon.Collections.Hits.collection.restore()
    Coreon.Models.ConceptSearch.restore()
    Backbone.history.stop()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "initialize()", ->

    it "assigns view", ->
      view = new Backbone.View
      @router.initialize view
      current = @router.view
      expect(current).to.equal view

  describe "search()", ->

    it "is routed", ->
      @router.search = sinon.spy()
      @router._bindRoutes()
      @router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/search/description/movie", trigger: true
      @router.search.should.have.been.calledOnce
      @router.search.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", "description", "movie"

    it "is routed with target being optional", ->
      @router.search = sinon.spy()
      @router._bindRoutes()
      @router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/search/movie", trigger: true
      @router.search.should.have.been.calledOnce
      @router.search.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", null, "movie"

    it "creates search", ->
      @router.search "c0ffeebabe23c0ffeebabe42", "terms", "gun"
      Coreon.Models.ConceptSearch.should.have.been.calledWithNew
      Coreon.Models.ConceptSearch.should.have.been.calledWith
        query: "gun"
        target: "terms"

  describe "show()", ->

    beforeEach ->
      sinon.stub Coreon.Models.Concept, "find", =>
        @concept = new Backbone.Model
        @concept.sync = sinon.spy()
        @concept

    afterEach ->
      Coreon.Models.Concept.find.restore()

    it "is routed", ->
      @router.show = sinon.spy()
      @router._bindRoutes()
      @router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/507f191e810c19729de860ea", trigger: true
      @router.show.should.have.been.calledOnce
      @router.show.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", "507f191e810c19729de860ea"

    it "is not routed for ids not matching the format of a MongoDB ObjectId", ->
      @router.show = sinon.spy()
      @router._bindRoutes()
      @router.navigate "/thisisthewrongformat/concepts/1234", trigger: true
      @router.show.should.not.have.been.called

    it "updates selection", ->
      @router.show "123"
      @collection.reset.should.have.been.calledOnce
      @collection.reset.should.have.been.calledWith [ result: @concept ]

  describe "newWithParent()", ->

    context "with maintainer privileges", ->

      beforeEach ->
        @repo.set "user_roles", [ "user", "maintainer" ]
        sinon.stub Coreon.Helpers, "can", -> true

      afterEach ->
        Coreon.Helpers.can.restore()
        @repo.set "user_roles", [ "user" ]

      it "is routed", ->
        @router.newWithParent = sinon.spy()
        @router._bindRoutes()
        @router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/new/parent/c0ffeebabe42c0ffeebabe23", trigger: true
        @router.newWithParent.should.have.been.calledOnce
        @router.newWithParent.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", "c0ffeebabe42c0ffeebabe23"

    context "without maintainer privileges", ->

      beforeEach ->
        sinon.stub Backbone.history, "navigate"
        sinon.stub Coreon.Helpers, "can", -> false

      afterEach ->
        Coreon.Helpers.can.restore()
        Backbone.history.navigate.restore()

      it "redirects to start page when not able to create a concept", ->
        @router.newWithParent()
        Backbone.history.navigate.should.have.been.calledOnce
        Backbone.history.navigate.should.have.been.calledWith "/"


  describe "new()", ->

    context "with maintainer privileges", ->

      beforeEach ->
        @repo.set "user_roles", [ "user", "maintainer" ]
        sinon.stub Coreon.Helpers, "can", -> true

      afterEach ->
        Coreon.Helpers.can.restore()
        @repo.set "user_roles", [ "user" ]

      it "is routed", ->
        @router.new = sinon.spy()
        @router._bindRoutes()
        @router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/new", trigger: true
        @router.new.should.have.been.calledOnce

      it "is routed with additional params", ->
        @router.new = sinon.spy()
        @router._bindRoutes()
        @router.navigate "/c0ffeebabe23c0ffeebabe42/concepts/new/terms/de/waffe", trigger: true
        @router.new.should.have.been.calledOnce
        @router.new.should.have.been.calledWith "c0ffeebabe23c0ffeebabe42", "de", "waffe"

    context "without maintainer privileges", ->

      beforeEach ->
        sinon.stub Backbone.history, "navigate"
        sinon.stub Coreon.Helpers, "can", -> false

      afterEach ->
        Coreon.Helpers.can.restore()
        Backbone.history.navigate.restore()

      it "redirects to start page when not able to create a concept", ->
        @router.new()
        Backbone.history.navigate.should.have.been.calledOnce
        Backbone.history.navigate.should.have.been.calledWith "/"
