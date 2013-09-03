#= require spec_helper
#= require routers/concepts_router
#= require config/application

describe "Coreon.Routers.ConceptsRouter", ->

  beforeEach ->
    @repo = new Backbone.Model user_roles: [ "user" ]
    @search = fetch:->
    @collection = new Backbone.Collection
    @collection.reset = sinon.spy()
    @collection.findByResult = ->
    sinon.stub Coreon.Collections.Hits, "collection", => @collection
    sinon.stub Coreon.Models, "ConceptSearch", => @search
    sinon.stub Coreon.Views.Concepts, "ConceptListView", => @list_view = new Backbone.View

    @view =
      repository:=> @repo
      query:->
      switch:->

    @router = new Coreon.Routers.ConceptsRouter @view
    Backbone.history.start(silent:true)

  afterEach ->
    Coreon.Collections.Hits.collection.restore()
    Coreon.Models.ConceptSearch.restore()
    Coreon.Views.Concepts.ConceptListView.restore()
    Backbone.history.stop()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "initialize()", ->

    it "assigns view", ->
      view = new Backbone.View
      @router
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


  describe "search()", ->
    beforeEach ->
      sinon.stub Coreon.Views.Concepts, "ConceptView", -> new Backbone.View

    afterEach ->
      Coreon.Views.Concepts.ConceptView.restore()

    it "creates search", ->
      @router.search "c0ffeebabe23c0ffeebabe42", "terms", "gun"
      Coreon.Models.ConceptSearch.should.have.been.calledWithNew
      Coreon.Models.ConceptSearch.should.have.been.calledWith
        path: "concepts/search"
        query: "gun"
        target: "terms"
      Coreon.Views.Concepts.ConceptListView.should.have.been.calledWithNew
      Coreon.Views.Concepts.ConceptListView.should.have.been.calledWith
        model: @search

  describe "show()", ->

    beforeEach ->
      sinon.stub Coreon.Views.Concepts, "ConceptView", -> new Backbone.View
      sinon.stub Coreon.Models.Concept, "find", =>
        @concept = new Backbone.Model
        @concept.sync = sinon.spy()
        @concept

    afterEach ->
      Coreon.Models.Concept.find.restore()
      Coreon.Views.Concepts.ConceptView.restore()

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

    it "renders concept details", ->
      @router.show "c0ffeebabe23c0ffeebabe42", "123"
      Coreon.Models.Concept.find.should.have.been.calledOnce
      Coreon.Models.Concept.find.should.have.been.calledWith "123", fetch: yes
      Coreon.Views.Concepts.ConceptView.should.have.been.called.withNew
      Coreon.Views.Concepts.ConceptView.should.have.been.calledWith
        model: @concept

    it "updates selection", ->
      @router.show "123"
      @collection.reset.should.have.been.calledOnce
      @collection.reset.should.have.been.calledWith [ result:@concept ]

  describe "newWithParent()", ->
    beforeEach ->
      sinon.stub Coreon.Views.Concepts, "NewConceptView", (opts)=>
        @concept = opts.model if opts.model

    afterEach ->
      Coreon.Views.Concepts.NewConceptView.restore()

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

      it "switches to new concept form", ->
        @router.newWithParent "c0ffeebabe23c0ffeebabe42", "c0ffeebabe42c0ffeebabe23"
        Coreon.Views.Concepts.NewConceptView.should.have.been.calledOnce
        Coreon.Views.Concepts.NewConceptView.should.have.been.calledWithNew
        Coreon.Views.Concepts.NewConceptView.should.have.been.calledWith
          model: @concept
        @concept.isNew().should.be.true
        @concept.get("super_concept_ids").should.eql ["c0ffeebabe42c0ffeebabe23"]

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

    beforeEach ->
      sinon.stub Coreon.Views.Concepts, "NewConceptView", (opts)=>
        @concept = opts.model if opts.model

    afterEach ->
      Coreon.Views.Concepts.NewConceptView.restore()

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

      it "switches to new concept form", ->
        @router.new()
        Coreon.Views.Concepts.NewConceptView.should.have.been.calledOnce
        Coreon.Views.Concepts.NewConceptView.should.have.been.calledWithNew
        Coreon.Views.Concepts.NewConceptView.should.have.been.calledWith
          model: @concept
        @concept.isNew().should.be.true

      it "populates terms from params", ->
        @router.new "c0ffeebabe23c0ffeebabe42", "de", "waffe"
        @concept.terms().should.have.lengthOf 1
        @concept.terms().at(0).get("lang").should.equal "de"
        @concept.terms().at(0).get("value").should.equal "waffe"

      it "updates selection", ->
        @router.new()
        @collection.reset.should.have.been.calledOnce
        @collection.reset.should.have.been.calledWith [ result:@concept ]

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
