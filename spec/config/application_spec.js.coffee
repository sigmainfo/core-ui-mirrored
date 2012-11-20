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
        auth_root  : "/api/auth/"
        graph_root : "/api/graph/"

    it "allows overriding defaults", ->
      @app.initialize auth_root: "/repository/"
      @app.options.auth_root.should.equal "/repository/"

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

    it "creates current hits", ->
      @app.initialize()
      @app.hits.should.be.an.instanceof Coreon.Collections.Hits
      @app.hits.length.should.equal 0

  describe "#start", ->

    it "can be chained", ->
      @app.start().should.equal @app
    
    it "takes options as argument", ->
      @app.start el: "#myapp"
      @app.options.el.should.equal "#myapp"

    it "creates view", ->
      @app.start el: "#coreon"
      @app.view.should.be.an.instanceof Coreon.Views.ApplicationView
      @app.view.model.should.equal @app.account
      @app.view.options.el.should.equal "#coreon"

    it "renders view", ->
      @app.start(el: "#konacha")
      @app.view.$el.should.not.be ":empty"

    it "creates search router", ->
      @app.start()
      @app.routers.search_router.should.be.an.instanceof Coreon.Routers.SearchRouter
      @app.routers.search_router.view.should.equal @app.view
      @app.routers.search_router.app.should.equal @app

    it "creates concepts router", ->
      @app.start()
      @app.routers.concepts_router.should.be.an.instanceof Coreon.Routers.ConceptsRouter
      @app.routers.concepts_router.view.should.equal @app.view
      @app.routers.concepts_router.app.should.equal @app

    it "starts history", ->
      Backbone.history.start = sinon.spy()
      @app.start()
      Backbone.history.start.should.have.been.calledWith pushState: true

  describe "#destroy", ->

    it "logs out account", ->
      @app.account.deactivate = sinon.spy()
      @app.destroy()
      @app.account.deactivate.should.have.been.calledOnce

    it "clears global reference", ->
      @app.destroy()
      Coreon.should.not.have.property "application"

  describe "#sync", ->
    
    it "is a shortcut to account.connections.sync", ->
      @app.account.connections.sync = sinon.spy()
      @app.sync "read", "myModel", data: "myData"
      @app.account.connections.sync.should.have.been.calledWith "read", "myModel", data: "myData"
