#= require spec_helper
#= require application

describe "Coreon.Application", ->

  beforeEach ->
    @app = new Coreon.Application

  afterEach ->
    Coreon.application = null
    Backbone.history?.stop()

  describe "#init", ->
    
    it "allows chaining", ->
      @app.init().should.equal @app

    it "makes app instance globally accessible", ->
      @app.init()
      Coreon.application.should.equal @app

    it "defaults root to /", ->
      @app.init()
      @app.options.root.should.equal "/"

    it "starts history", ->
      Backbone.history = new Backbone.History
      sinon.spy Backbone.history, "start"
      @app.init root: "/repo/"
      Backbone.history.start.should.have.been.calledWith pushState: true, root: "/repo/"
      Backbone.history.start.restore()

    context "layout", ->

      it "uses #app by default", ->
        $("#konacha").append $("<div>", id: "app")
        @app.init()
        $("#app").should.have "#coreon-footer"

      it "uses specified container", ->
        @app.init el: "#konacha"
        $("#konacha").should.have "#coreon-footer"
    

    context "Notifications", ->

      it "creates collection", ->
        @app.init()
        @app.notifications.should.be.an.instanceOf Coreon.Models.Notifications

    context "Account", ->

      it "creates model", ->
        @app.init()
        @app.account.should.be.an.instanceOf Coreon.Models.Account
        
      it "creates router", ->
        sinon.spy Coreon.Routers, "AccountRouter"
        @app.init()
        Coreon.Routers.AccountRouter.should.have.been.calledOnce
        Coreon.Routers.AccountRouter.restore()    
