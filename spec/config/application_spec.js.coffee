#= require spec_helper
#= require application

describe "Coreon.Application", ->

  beforeEach ->
    @app = new Coreon.Application

  afterEach ->
    Coreon.application = null
    Backbone.history?.stop()

  context "#init", ->
    
    beforeEach ->
      Backbone.history = new Backbone.History
      sinon.stub Backbone.history, "navigate"

    it "allows chaining", ->
      @app.init().should.equal @app

    it "makes app instance globally accessible", ->
      @app.init()
      Coreon.application.should.equal @app

    it "defaults root to /", ->
      @app.init()
      @app.options.root.should.equal "/"

    it "starts history", ->
      sinon.spy Backbone.history, "start"
      @app.init root: "/repo/"
      Backbone.history.start.should.have.been.calledWith pushState: true, root: "/repo/", silent: true

    context ".view", ->

      it "uses #app by default", ->
        $("#konacha").append $("<div>", id: "app")
        @app.init()
        $("#app").should.have "#coreon-tools"

      it "uses specified container", ->
        @app.init el: "#konacha"
        $("#konacha").should.have "#coreon-tools"

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
        
      it "creates notification on logout", ->
        @app.init()
        @app.account.trigger "logout"
        @app.notifications.length.should.equal 1
        @app.notifications.at(0).get("message").should.equal I18n.t "notifications.account.logout"

      it "creates notification on login", ->
        @app.init()
        @app.account.set "userName", "Wiliam Blake", silent: true
        @app.account.trigger "login"
        @app.notifications.length.should.equal 1
        @app.notifications.at(0).get("message").should.equal I18n.t "notifications.account.login", name: "Wiliam Blake"

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

