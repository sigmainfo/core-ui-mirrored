#= require spec_helper
#= require routers/repositories_router

describe "Coreon.Routers.RepositoriesRouter", ->
  
  beforeEach ->
    sinon.stub Coreon.Models.Repository, "current"
    sinon.stub Coreon.Models.Repository, "select"
    @view = new Backbone.View
    @view.switch = sinon.spy()
    @router = new Coreon.Routers.RepositoriesRouter @view
    Backbone.history.start()

  afterEach ->
    Backbone.history.stop()
    Coreon.Models.Repository.current.restore()
    Coreon.Models.Repository.select.restore()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "root()", ->
  
    it "is routed", ->
      @router.root = sinon.spy()
      @router._bindRoutes()
      @router.navigate "other"
      @router.navigate "", trigger: yes
      @router.root.should.have.been.calledOnce

    it "redirects to current repository", ->
      Coreon.Models.Repository.current.returns id: "my-repo-123"
      @router.navigate = sinon.spy()
      @router.root()
      @router.navigate.should.have.been.calledOnce
      @router.navigate.should.have.been.calledWith "my-repo-123", trigger: yes, replace: yes

    it "kills session when no repository is available", ->
      Coreon.Models.Repository.current.returns null
      @router.navigate = sinon.spy()
      @router.root()
      @router.navigate.should.have.been.calledWith "logout"

  describe "show()", ->

    beforeEach ->
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
      @router.show "my-repo-abcdef"
      Coreon.Models.Repository.select.should.have.been.calledWith "my-repo-abcdef"

    it "displays repository root", ->
      repo = id: "my-repo-abcdef"
      Coreon.Models.Repository.select.withArgs("my-repo-abcdef").returns repo
      @router.view.switch = sinon.spy()
      @router.show "my-repo-abcdef"
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledOnce
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledWithNew
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledWith model: repo
      @router.view.switch.should.have.been.calledWith @screen

    it "redirects to root when repository is not available", ->
      Coreon.Models.Repository.select.withArgs("ghost-repo-123").returns null
      @router.navigate = sinon.spy()
      @router.show "ghost-repo-123"
      @router.navigate.should.have.been.calledOnce
      @router.navigate.should.have.been.calledWith "", trigger: yes, replace: yes
