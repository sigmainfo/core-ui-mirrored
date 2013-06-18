#= require spec_helper
#= require routers/repositories_router

describe "Coreon.Routers.RepositoriesRouter", ->
  
  beforeEach ->
    @session = new Backbone.Model
    @session.currentRepository = -> null
    app = new Backbone.Model session: @session
    @view = new Backbone.View model: app
    @view.switch = sinon.spy()
    @router = new Coreon.Routers.RepositoriesRouter @view
    Backbone.history.start()

  afterEach ->
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

    it "redirects to current repository", ->
      @session.currentRepository = -> id: "my-repo-123"
      @router.navigate = sinon.spy()
      @router.root()
      @router.navigate.should.have.been.calledOnce
      @router.navigate.should.have.been.calledWith "my-repo-123", trigger: yes, replace: yes

    it "kills session when no repository is available", ->
      @session.currentRepository = -> null
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
      @session.set "current_repository_id", "other-repo-fghj", silent: yes 
      @router.show "my-repo-abcdef"
      @session.get("current_repository_id").should.equal "my-repo-abcdef"

    it "displays repository root", ->
      repo = id: "my-repo-abcdef"
      @session.currentRepository = =>
        repo if @session.get("current_repository_id") is "my-repo-abcdef"
      @router.view.switch = sinon.spy()
      @router.show "my-repo-abcdef"
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledOnce
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledWithNew
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledWith model: repo
      @router.view.switch.should.have.been.calledWith @screen

    it "redirects to root when repository is not available", ->
      @session.currentRepository = =>
        if @session.get("current_repository_id") is "ghost-repo-123"
          null
        else
          id: "other-repo-123"
      @router.navigate = sinon.spy()
      @router.show "ghost-repo-123"
      @router.navigate.should.have.been.calledOnce
      @router.navigate.should.have.been.calledWith "", trigger: yes, replace: yes
