#= require spec_helper
#= require application

describe "Coreon.Application", ->

  beforeEach ->
    @app = new Coreon.Application

  afterEach ->
    Coreon.application = null
    Backbone.history?.stop()

  context "#init", ->
    
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

    context ".view", ->

      it "uses #app by default", ->
        $("#konacha").append $("<div>", id: "app")
        @app.init()
        $("#app").should.have "#coreon-footer"

      it "uses specified container", ->
        @app.init el: "#konacha"
        $("#konacha").should.have "#coreon-footer"

      it "creates view instance", ->
        @app.init()
        @app.view.should.be.an.instanceOf Coreon.Views.ApplicationView

      it "connects view to model", ->
        @app.init()
        @app.view.model.should.equal @app
    

    context "Notifications", ->

      it "creates collection", ->
        @app.init()
        @app.notifications.should.be.an.instanceOf Coreon.Collections.Notifications

    context "Account", ->

      it "creates model", ->
        @app.init()
        @app.account.should.be.an.instanceOf Coreon.Models.Account
        
      it "creates router", ->
        sinon.spy Coreon.Routers, "AccountRouter"
        @app.init()
        Coreon.Routers.AccountRouter.should.have.been.calledOnce
        Coreon.Routers.AccountRouter.restore()    

    context "#notify", ->

      beforeEach ->
        @app.init()

      it "creates notification with provided message", ->
        @app.notify "Who pays the rent on time."
        @app.notifications.at(0).get("message").should.equal "Who pays the rent on time."

      it "returns notification instance", ->
        @app.notify("Who pays the rent on time.").should.equal @app.notifications.at(0)

      it "creates new notifications on top of stack", ->
        @app.notify "Yeah, a landlord's dream: a paralyzed tenant with no tongue."
        @app.notify "Who pays the rent on time."
        @app.notifications.at(0).get("message").should.equal "Who pays the rent on time."

