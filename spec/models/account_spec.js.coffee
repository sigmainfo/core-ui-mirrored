#= require spec_helper
#= require models/account

describe "Coreon.Models.Account", ->
    
  beforeEach ->
    @account = new Coreon.Models.Account

  afterEach ->
    @account.destroy()

  it "is a Backbone model", ->
    @account.should.be.an.instanceof Backbone.Model

  describe "with defaults", ->
    
    it "is inactive", ->
      @account.get("active").should.be.false

    it "has api paths set on domain", ->
      @account.get("auth_root").should.equal "/api/auth/"
      @account.get("graph_root").should.equal "/api/graph/"

    it "has no user name", ->
      @account.get("name").should.equal ""
      
  
  describe "#initialize", ->
    
    it "creates notifications", ->
      @account.notifications.should.be.an.instanceof Coreon.Collections.Notifications

    it "creates connections", ->
      @account.connections.should.be.an.instanceof Coreon.Collections.Connections

  describe "#activate", ->
    
    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (@request) =>

    afterEach ->
      @xhr.restore()

    it "calls auth service with credentials", ->
      @account.set "auth_root", "https://api.coreon.com/auth/"
      @account.activate("Nobody", "se7en!")
      @request.url.should.equal "https://api.coreon.com/auth/login"
      @request.method.should.equal "POST"
      @request.requestHeaders["Accept"].should.contain "application/json"
      @request.requestBody.should.equal "login=Nobody&password=se7en!"

    it "adds connection for request", ->
      @account.activate("Nobody", "se7en!")
      @account.connections.length.should.equal 1
      @account.connections.first().get("xhr").should.respondTo "abort"
      @account.connections.first().get("model").should.equal @account
      @account.connections.first().get("options").data.login.should.equal "Nobody"

    it "triggers callback on success", ->
      @account.onActivated = sinon.spy()
      @account.activate("Nobody", "se7en!")
      @request.respond 200, {"Content-Type": "application/json"}, '{"message": "Logged in"}'
      @account.onActivated.should.have.been.calledOnce

  describe "#onActivated", ->

    beforeEach ->
      sinon.stub I18n, "t"
      @data =
        user:
          name: ""
    afterEach ->
      I18n.t.restore()

    it "adjusts state", ->
      @account.onActivated @data
      @account.get("active").should.be.true

    it "stores user name", ->
      @data.user.name = "William Blake"
      @account.onActivated @data
      @account.get("name").should.equal "William Blake"
      localStorage.getItem("name").should.equal "William Blake"

    it "sets auth token", ->
      @account.on "sync", spy = sinon.spy()
      @data.auth_token = "xxx-1234-abcd"
      @account.onActivated @data
      @account.get("session").should.equal "xxx-1234-abcd"
      localStorage.getItem("session").should.equal "xxx-1234-abcd"

    it "triggers event", ->
      spy = sinon.spy()
      @account.on "activated", spy
      @account.onActivated @data
      spy.should.have.been.calledOnce

    it "creates notification", ->
      @account.message = sinon.spy()
      I18n.t.withArgs("notifications.account.login", name: "William Blake").returns "Hello, William Blake!" 
      @data.user.name = "William Blake"
      @account.onActivated @data
      @account.message.should.have.been.calledWith "Hello, William Blake!"

    it "clears notifications", ->
      @account.notifications.reset = sinon.spy()
      @account.onActivated @data
      @account.notifications.reset.should.have.been.calledOnce

  describe "#deactivate", ->

    beforeEach ->
      sinon.stub I18n, "t"
      @account.set "active", true

    afterEach ->
      I18n.t.restore()

    it "adjusts state", ->
      @account.deactivate()
      @account.get("active").should.be.false
   
    it "resets name", ->
      @account.deactivate()
      @account.get("name").should.equal ""
  
    it "resets session", ->
      @account.save
          name: "Dead Man"
          session: "1234abcd-xxxx"
      @account.deactivate()
      expect(localStorage.getItem "name").to.be.null
      expect(localStorage.getItem "session").to.be.null

    it "triggers event", ->
      spy = sinon.spy()
      @account.on "deactivated", spy
      @account.deactivate()
      spy.should.have.been.calledOnce

    it "creates notification", ->
      @account.message = sinon.spy()
      I18n.t.withArgs("notifications.account.logout").returns "Logged out"
      @account.deactivate()
      @account.message.should.have.been.calledWith "Logged out"

    it "clears notifications", ->
      @account.notifications.reset = sinon.spy()
      @account.deactivate()
      @account.notifications.reset.should.have.been.calledOnce

  describe "#sync", ->
    
    describe "create, update", ->
      
      it "stores name and session", ->
        @account.save
          name: "Dead Man"
          session: "1234abcd-xxxx"
        @account.sync "create", @account
        localStorage.getItem("name").should.equal "Dead Man"
        localStorage.getItem("session").should.equal "1234abcd-xxxx"

    describe "read", ->
      
      it "updates values from store", ->
        localStorage.setItem "name", "Jim Jarmusch"
        localStorage.setItem "session", "0987654321"
        @account.fetch()
        @account.get("name").should.equal "Jim Jarmusch"
        @account.get("session").should.equal "0987654321"

      it "syncs active state", ->
        localStorage.setItem "session", "0987654321"
        @account.fetch()
        @account.get("active").should.be.true
        localStorage.removeItem "session"
        @account.fetch()
        @account.get("active").should.be.false

    describe "delete", ->

      it "resets name and session", ->
        @account.save
          name: "Dead Man"
          session: "1234abcd-xxxx"
        @account.destroy()
        expect(localStorage.getItem "name").to.be.null
        expect(localStorage.getItem "session").to.be.null

  describe "#onUnauthorized", ->

    beforeEach ->
      @account.save
        name: "Dead Man"
        session: "1234abcd-xxxx"
    
    it "is triggered by errors on connections", ->
      @account.onUnauthorized = sinon.spy()
      @account.initialize()
      @account.connections.trigger "error:403"
      @account.onUnauthorized.should.have.been.calledOnce

    it "clears session ", ->
      @account.onUnauthorized()
      expect(@account.get "session").to.not.exist

    it "triggers event", ->
      spy = sinon.spy()
      @account.on "unauthorized", spy
      @account.onUnauthorized()
      spy.should.have.been.calledOnce

  describe "#destroy", ->
    
    it "destroys notifications", ->
      @account.notifications.destroy = sinon.spy()
      @account.destroy()
      @account.notifications.destroy.should.have.been.calledOnce
      
    it "destroys connections", ->
      @account.connections.destroy = sinon.spy()
      @account.destroy()
      @account.connections.destroy.should.have.been.calledOnce
