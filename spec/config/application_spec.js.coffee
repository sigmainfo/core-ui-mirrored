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
        $("#app").should.have "#coreon-top"

      it "uses specified container", ->
        @app.init el: "#konacha"
        $("#konacha").should.have "#coreon-top"

      it "creates view instance", ->
        @app.init()
        @app.view.should.be.an.instanceOf Coreon.Views.ApplicationView

      it "connects view to model", ->
        @app.init()
        @app.view.model.should.equal @app
    

    context "Notifications", ->

      beforeEach ->
        @app.init()

      it "creates collection", ->
        @app.notifications.should.be.an.instanceOf Coreon.Collections.Notifications

      it "creates notification on logout", ->
        @app.account.trigger "logout"
        @app.notifications.length.should.equal 1
        @app.notifications.at(0).get("message").should.equal I18n.t "notifications.account.logout"

      it "creates notification on login", ->
        @app.account.set "userName", "Wiliam Blake", silent: true
        @app.account.trigger "login"
        @app.notifications.length.should.equal 1
        @app.notifications.at(0).get("message").should.equal I18n.t "notifications.account.login", name: "Wiliam Blake"

      it "clears previous notifications on login", ->
        @app.account.trigger "logout"
        @app.account.trigger "login"
        @app.notifications.length.should.equal 1

      it "clears previous notifications on logout", ->
        @app.account.trigger "login"
        @app.account.trigger "logout"
        @app.notifications.length.should.equal 1

    context "Account", ->

      beforeEach ->
        @app.init()

      it "creates model", ->
        @app.account.should.be.an.instanceOf Coreon.Models.Account
        
    describe "#notify", ->

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

    describe "#alert", ->

      beforeEach ->
        @app.init()
      
      it "creates notifications of type error", ->
        @app.alert "Terrible is what it is."
        @app.notifications.at(0).get("message").should.equal "Terrible is what it is."
        @app.notifications.at(0).get("type").should.equal "error"

      it "returns notification instance", ->
        @app.alert("I am what I am.").should.equal @app.notifications.at(0)
         
      it "creates new notifications on top of stack", ->
        @app.alert "Yeah, a landlord's dream: a paralyzed tenant with no tongue."
        @app.alert "Who pays the rent on time."
        @app.notifications.at(0).get("message").should.equal "Who pays the rent on time."

  describe "Ajax", ->
    
    beforeEach ->
      @server = sinon.fakeServer.create()
      @app.init()
    
    afterEach ->
      @server.restore()

    context "on error", ->

      beforeEach ->
        CoreClient.Auth.root_url = "/api"
        @server.respondWith [
          400,
          { "Content-Type": "application/json" },
          JSON.stringify
            message: "Could not parse JSON"
            code: "errors.json.parse"
        ]

      it "displays I18n error message", ->
        sinon.stub I18n, "t"
        I18n.t.withArgs("errors.json.parse").returns "Try it again, Dude." 
        jQuery.ajax "/api/can/be/anything"
        @server.respond()
        try
          @app.notifications.length.should.equal 1
          @app.notifications.at(0).get("type").should.equal "error"
          @app.notifications.at(0).get("message").should.equal "Try it again, Dude."
        finally
          I18n.t.restore()

      it "display provided error message as a fallback", -> 
        jQuery.ajax "/api/can/be/anything"
        @server.respond()
        @app.notifications.at(0).get("message").should.equal "Could not parse JSON"

      it "handles API errors only", ->
        CoreClient.Auth.root_url = "/api/auth"
        CoreClient.Graph.root_url = "/api/graph"
        jQuery.ajax "/api/auth/login"
        jQuery.ajax "/can/be/anything"
        jQuery.ajax "/api/graph/foo/bar/baz"
        @server.respond()
        @app.notifications.length.should.equal 2

      it "displays generic error when no message given", ->
        sinon.stub I18n, "t", (scope, options) ->
          switch scope
            when "errors.generic" then "An error occured."
            when "not.exist" then options.defaultValue
        jQuery.ajax "/api/can/be/anything"
        @server.respond [500, {},
          JSON.stringify
            code: "not.exist"
        ]
        try
          @app.notifications.at(0).get("message").should.equal "An error occured."
        finally
          I18n.t.restore()
      
      it "displays generic error when response is invalid", ->
        sinon.stub I18n, "t"
        I18n.t.withArgs("errors.generic").returns "An error occured." 
        jQuery.ajax "/api/can/be/anything"
        @server.respond [500, {},
          JSON.stringify
            foo: "bar"
        ]
        try
          @app.notifications.at(0).get("message").should.equal "An error occured."
        finally
          I18n.t.restore()

      it "displays message when service not available", ->
        sinon.stub I18n, "t"
        I18n.t.withArgs("errors.service.unavailable").returns "Service currently unavailable." 
        @app.ajaxErrorHandler("event", {readyState: 0}, {url: "/api/foo"}, "")
        try
          @app.notifications.at(0).get("message").should.equal "Service currently unavailable."
        finally
          I18n.t.restore()

        


