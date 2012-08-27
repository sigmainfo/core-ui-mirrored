#= require spec_helper
#= require application

describe "Coreon.Application", ->

  beforeEach ->
    @app = new Coreon.Application
    Backbone.history =
      start: ->
      route: ->

  afterEach ->
    @app.destroy()
    delete Backbone.history

  it "creates global reference", ->
    Coreon.application.should.equal @app

  it "enforces single instance", ->
    (-> new Coreon.Application).should.throw "Coreon application does already exist"
    

  describe "#initialize", ->
    
    it "sets default options", ->
      @app.options.should.eql
        el         : "#app"
        app_root   : "/"
        auth_root  : "/api/auth/"
        graph_root : "/api/graph/"

    it "allows overriding defaults", ->
      @app.initialize app_root: "/repository/"
      @app.options.app_root.should.equal "/repository/"

    it "creates account", ->
      @app.initialize
        auth_root  : "/api/auth_root/"
        graph_root : "/api/graph_root/"
      @app.account.should.be.an.instanceof Coreon.Models.Account
      @app.account.get("auth_root").should.equal "/api/auth_root/"
      @app.account.get("graph_root").should.equal "/api/graph_root/"

    it "fetches account", ->
      localStorage.setItem "session", "my-auth-token"
      @app.account.fetch = sinon.spy()
      @app.initialize()
      @app.account.get("session").should.equal "my-auth-token"

    it "creates concepts", ->
      @app.concepts.should.be.an.instanceof Coreon.Collections.Concepts

  describe "#start", ->

    it "can be chained", ->
      @app.start().should.equal @app
    
    it "takes options as argument", ->
      @app.start el: "#myapp"
      @app.options.el.should.equal "#myapp"

    it "creates view", ->
      @app.start el: "#coreon"
      @app.view.should.be.an.instanceof Coreon.Views.ApplicationView
      @app.view.model.should.equal @app
      @app.view.options.el.should.equal "#coreon"

    it "renders view", ->
      @app.start(el: "#konacha")
      @app.view.$el.should.not.be ":empty"

    it "creates concepts router", ->
      @app.start()
      @app.routers.concepts_router.should.be.an.instanceof Coreon.Routers.ConceptsRouter
      @app.routers.concepts_router.collection.should.equal @app.concepts

    it "starts history", ->
      Backbone.history.start = sinon.spy()
      @app.start app_root: "/app/root/"
      Backbone.history.start.should.have.been.calledWith
        pushState: true
        root: "/app/root/"
        silent: true
      

  describe "#destroy", ->

    it "logs out account", ->
      @app.account.deactivate = sinon.spy()
      @app.destroy()
      @app.account.deactivate.should.have.been.calledOnce

    it "clears global reference", ->
      @app.destroy()
      Coreon.should.not.have.property "application"
