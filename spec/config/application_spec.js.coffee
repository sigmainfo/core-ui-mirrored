#= require spec_helper
#= require application

describe "Coreon.Application", ->

  beforeEach ->
    @request = $.Deferred()
    sinon.stub Backbone.history, "start"
    sinon.stub Coreon.Routers, "SessionsRouter"
    sinon.stub Coreon.Routers, "RepositoriesRouter"
    sinon.stub Coreon.Routers, "ConceptsRouter"
    sinon.stub Coreon.Routers, "SearchRouter"
    sinon.stub Coreon.Models.Session, "load", => @request
    sinon.stub Coreon.Views, "ApplicationView", =>
      @view = new Backbone.View arguments...
    @app = new Coreon.Application auth_root: "https://auth.coreon.com"

  afterEach ->
    Backbone.history.start.restore()
    Coreon.Routers.SessionsRouter.restore()
    Coreon.Routers.RepositoriesRouter.restore()
    Coreon.Routers.ConceptsRouter.restore()
    Coreon.Routers.SearchRouter.restore()
    Coreon.Models.Session.load.restore()
    Coreon.Views.ApplicationView.restore()
    Coreon.application = null

  it "is a Backbone model", ->
    @app.should.be.an.instanceof Backbone.Model

  describe "defaults", ->
    
    it "chooses sensible default for container selector", ->
      @app.get("el").should.equal "#coreon-app"

  describe "initialize()", ->

    it "makes instance globally accessible", ->
      Coreon.application.should.equal @app
    
    it "enforces single instance", ->
      (-> new Coreon.Application).should.throw "Coreon application already initialized"

    it "configures auth root on session", ->
      Coreon.Models.Session.auth_root.should.equal "https://auth.coreon.com"

    it "creates application view", ->
      Coreon.Views.ApplicationView.should.have.been.calledOnce
      Coreon.Views.ApplicationView.should.have.been.calledWithNew
      Coreon.Views.ApplicationView.should.have.been.calledWith model: @app, el: "#coreon-app"

    it "creates sessions router", ->
      Coreon.Routers.SessionsRouter.should.have.been.calledOnce
      Coreon.Routers.SessionsRouter.should.have.been.calledWithNew
      Coreon.Routers.SessionsRouter.should.have.been.calledWith @view

    it "creates repositories router", ->
      Coreon.Routers.RepositoriesRouter.should.have.been.calledOnce
      Coreon.Routers.RepositoriesRouter.should.have.been.calledWithNew
      Coreon.Routers.RepositoriesRouter.should.have.been.calledWith @view

    it "creates concepts router", ->
      Coreon.Routers.ConceptsRouter.should.have.been.calledOnce
      Coreon.Routers.ConceptsRouter.should.have.been.calledWithNew
      Coreon.Routers.ConceptsRouter.should.have.been.calledWith @view

    it "creates concepts router", ->
      Coreon.Routers.SearchRouter.should.have.been.calledOnce
      Coreon.Routers.SearchRouter.should.have.been.calledWithNew
      Coreon.Routers.SearchRouter.should.have.been.calledWith @view

  describe "start()", ->

    it "can be chained", ->
      @app.start().should.equal @app

    it "throws error when no auth root was given", ->
      @app.unset "auth_root", silent: true
      (=> @app.start() ).should.throw "Authorization service root URL not given"
      
    it "loads session", ->
      @app.set "auth_root", "https://auth.me", silent: true
      @app.start()
      Coreon.Models.Session.load.should.have.been.calledOnce
      Coreon.Models.Session.load.should.have.been.calledWith "https://auth.me"
    
    it "assigns session", ->
      session = new Backbone.Model
      @app.start()
      @request.resolve session
      @app.get("session").should.equal session

    it "triggers change event for empty session", ->
      spy = sinon.spy()
      @app.on "change:session", spy
      @app.start()
      @request.resolve null
      spy.should.have.been.calledOnce
