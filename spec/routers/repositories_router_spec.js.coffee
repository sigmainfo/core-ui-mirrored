#= require spec_helper
#= require routers/repositories_router

describe "Coreon.Routers.RepositoriesRouter", ->

  beforeEach ->
    @view = new Backbone.View
    @view.repository = -> null
    @view.query = -> ""
    @view.switch = sinon.spy()

    @hits = reset: sinon.spy()
    sinon.stub Coreon.Collections.Hits, "collection", => @hits

    @clips = reset: sinon.spy()
    sinon.stub Coreon.Collections.Clips, "collection", => @clips

    @router = new Coreon.Routers.RepositoriesRouter @view

    Backbone.history.start silent: yes

  afterEach ->
    Coreon.Collections.Hits.collection.restore()
    Coreon.Collections.Clips.collection.restore()
    Backbone.history.stop()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "root()", ->

    it "is routed", ->
      @router.root = sinon.spy()
      @router._bindRoutes()
      @router.navigate "other"
      @router.navigate "", trigger: yes
      @router.root.should.have.been.calledOnce

    it "redirects to default repository", ->
      @view.repository = sinon.stub()
      @view.repository.withArgs(null).returns id: "my-repo-123"
      @router.navigate = sinon.spy()
      @router.root()
      @router.navigate.should.have.been.calledOnce
      @router.navigate.should.have.been.calledWith "my-repo-123", trigger: yes, replace: yes

    it "kills session when no repository is available", ->
      @view.repository = -> null
      @router.navigate = sinon.spy()
      @router.root()
      @router.navigate.should.have.been.calledWith "logout"

  describe "show()", ->

    beforeEach ->
      @concepts = reset: sinon.spy()
      sinon.stub Coreon.Views.Repositories, "RepositoryView", =>
        @screen = new Backbone.View arguments...

    afterEach ->
      Coreon.Views.Repositories.RepositoryView.restore()

    it "is routed", ->
      @router.show = sinon.spy()
      @router._bindRoutes()
      @router.navigate "50990fb960303934ea000041", trigger: yes
      @router.show.should.have.been.calledOnce

    it "switches repository", ->
      @router.navigate = ->
      @view.repository = sinon.spy()
      @router.show "my-repo-abcdef"
      @view.repository.should.have.been.calledOnce
      @view.repository.should.have.been.calledWith "my-repo-abcdef"

    it "displays repository root", ->
      repository = new Backbone.Model "my-repo-abcdef"
      @view.repository = -> repository
      @router.view.switch = sinon.spy()
      @router.show "my-repo-abcdef"
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledOnce
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledWithNew
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledWith model: repository
      @router.view.switch.should.have.been.calledWith @screen

    it "changes fragment when current repo is different from param", ->
      @router.navigate = sinon.spy()
      @view.repository = -> id: "some-other-id-567"
      @router.show "my-repo-abcdef"
      @router.navigate.should.have.been.calledWithExactly "some-other-id-567"

    it "redirects to root when repository is not available", ->
      @view.repository = -> null
      @router.navigate = sinon.spy()
      @router.show "ghost-repo-123"
      @router.navigate.should.have.been.calledOnce
      @router.navigate.should.have.been.calledWith "", trigger: yes, replace: yes
