#= require spec_helper
#= require models/session

describe "Coreon.Models.Session", ->
    
  beforeEach ->
    @session = new Coreon.Models.Session

  afterEach ->
    @session.destroy()

  it "is a Backbone model", ->
    @session.should.be.an.instanceof Backbone.Model

  describe "with defaults", ->
    
    it "is inactive", ->
      @session.get("active").should.be.false

    it "has api paths set on domain", ->
      @session.get("auth_root").should.equal "/api/auth/"
      @session.get("graph_root").should.equal "/api/graph/"

    it "has no user name or login", ->
      @session.get("name").should.equal ""
      
  
  describe "#initialize", ->
    
    it "creates notifications", ->
      @session.notifications.should.be.an.instanceof Coreon.Collections.Notifications

    it "creates connections", ->
      @session.connections.should.be.an.instanceof Coreon.Collections.Connections
      @session.connections.session.should.equal @session

  describe "#activate", ->
    
    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (@request) =>

    afterEach ->
      @xhr.restore()

    it "sets login on model", ->
      @session.activate("Nobody", "se7en!")
      @session.get("login").should.equal "Nobody"


    it "calls auth service with credentials", ->
      @session.set "auth_root", "https://api.coreon.com/auth/"
      @session.activate("Nobody", "se7en!")
      @request.url.should.equal "https://api.coreon.com/auth/login"
      @request.method.should.equal "POST"
      @request.requestHeaders["Accept"].should.contain "application/json"
      @request.requestBody.should.equal "login=Nobody&password=se7en!"

    it "adds connection for request", ->
      @session.activate("Nobody", "se7en!")
      @session.connections.length.should.equal 1
      @session.connections.first().get("xhr").should.respondTo "abort"
      @session.connections.first().get("model").should.equal @session
      @session.connections.first().get("options").data.login.should.equal "Nobody"

    it "triggers callback on success", ->
      @session.onActivated = sinon.spy()
      @session.activate("Nobody", "se7en!")
      @request.respond 200, {"Content-Type": "application/json"}, '{"message": "Logged in"}'
      @session.onActivated.should.have.been.calledOnce

  describe "#onActivated", ->

    beforeEach ->
      sinon.stub I18n, "t"
      @data =
        user:
          name: ""

    afterEach ->
      I18n.t.restore()

    it "adjusts state", ->
      @session.onActivated @data
      @session.get("active").should.be.true

    it "stores user name and login", ->
      @data.user.name = "William Blake"
      @session.set "login", "w.blake"
      @session.onActivated @data
      @session.get("name").should.equal "William Blake"
      localStorage.getItem("name").should.equal "William Blake"
      localStorage.getItem("login").should.equal "w.blake"

    it "sets auth token", ->
      @data.auth_token = "xxx-1234-abcd"
      @session.onActivated @data
      @session.get("token").should.equal "xxx-1234-abcd"
      localStorage.getItem("token").should.equal "xxx-1234-abcd"

    it "triggers event", ->
      spy = sinon.spy()
      @session.on "activated", spy
      @session.onActivated @data
      spy.should.have.been.calledOnce

    it "creates notification", ->
      @session.message = sinon.spy()
      I18n.t.withArgs("notifications.account.login", name: "William Blake").returns "Hello, William Blake!" 
      @data.user.name = "William Blake"
      @session.onActivated @data
      @session.message.should.have.been.calledWith "Hello, William Blake!"

    it "clears notifications", ->
      @session.notifications.reset = sinon.spy()
      @session.onActivated @data
      @session.notifications.reset.should.have.been.calledOnce

  describe "#reactivate", ->
    
    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (@request) =>

    afterEach ->
      @xhr.restore()

    it "calls auth service with credentials", ->
      @session.set
        auth_root: "https://api.coreon.com/auth/"
        login: "Nobody"
      @session.reactivate "se7en!"
      @request.url.should.equal "https://api.coreon.com/auth/login"
      @request.method.should.equal "POST"
      @request.requestHeaders["Accept"].should.contain "application/json"
      @request.requestBody.should.equal "login=Nobody&password=se7en!"

    it "adds connection for request", ->
      @session.set "login", "Nobody"
      @session.reactivate "se7en!"
      @session.connections.length.should.equal 1
      @session.connections.first().get("xhr").should.respondTo "abort"
      @session.connections.first().get("model").should.equal @session
      @session.connections.first().get("options").data.login.should.equal "Nobody"

    it "triggers callback on success", ->
      @session.onReactivated = sinon.spy()
      @session.reactivate "se7en!"
      @request.respond 200, {"Content-Type": "application/json"}, '{"message": "Logged in"}'
      @session.onReactivated.should.have.been.calledOnce

  describe "#onReactivated", ->
    
    it "updates session", ->
      @data.auth_token = "newsession-1234-abcd"
      @session.onReactivated @data
      @session.get("token").should.equal "newsession-1234-abcd"
      localStorage.getItem("token").should.equal "newsession-1234-abcd"

    it "triggers event", ->
      spy = sinon.spy()
      @session.on "reactivated", spy
      @session.onReactivated @data
      spy.should.have.been.calledOnce

  describe "#deactivate", ->

    beforeEach ->
      sinon.stub I18n, "t"
      @session.set "active", true

    afterEach ->
      I18n.t.restore()

    it "adjusts state", ->
      @session.deactivate()
      @session.get("active").should.be.false
   
    it "resets name", ->
      @session.deactivate()
      @session.get("name").should.equal ""
  
    it "resets session", ->
      @session.save
          name: "Dead Man"
          token: "1234abcd-xxxx"
      @session.deactivate()
      expect(localStorage.getItem "name").to.be.null
      expect(localStorage.getItem "token").to.be.null

    it "triggers event", ->
      spy = sinon.spy()
      @session.on "deactivated", spy
      @session.deactivate()
      spy.should.have.been.calledOnce

    it "creates notification", ->
      @session.message = sinon.spy()
      I18n.t.withArgs("notifications.account.logout").returns "Logged out"
      @session.deactivate()
      @session.message.should.have.been.calledWith "Logged out"

    it "clears notifications", ->
      @session.notifications.reset = sinon.spy()
      @session.deactivate()
      @session.notifications.reset.should.have.been.calledOnce

  describe "#sync", ->
    
    describe "create, update", ->
      
      it "stores login, name and session", ->
        @session.save
          login: "nobody"
          name: "Dead Man"
          token: "1234abcd-xxxx"
        @session.sync "create", @session
        localStorage.getItem("name").should.equal "Dead Man"
        localStorage.getItem("token").should.equal "1234abcd-xxxx"
        localStorage.getItem("login").should.equal "nobody"

    describe "read", ->
      
      it "updates values from store", ->
        localStorage.setItem "name", "Jim Jarmusch"
        localStorage.setItem "login", "nobody"
        localStorage.setItem "token", "0987654321"
        @session.fetch()
        @session.get("name").should.equal "Jim Jarmusch"
        @session.get("login").should.equal "nobody"
        @session.get("token").should.equal "0987654321"

      it "syncs active state", ->
        localStorage.setItem "token", "0987654321"
        @session.fetch()
        @session.get("active").should.be.true
        localStorage.removeItem "token"
        @session.fetch()
        @session.get("active").should.be.false

    describe "delete", ->

      it "resets name and session", ->
        @session.save
          name: "Dead Man"
          session: "1234abcd-xxxx"
          login: "w.blake"
        @session.destroy()
        expect(localStorage.getItem "name").to.be.null
        expect(localStorage.getItem "token").to.be.null
        expect(localStorage.getItem "login").to.be.null

  describe "#onUnauthorized", ->

    beforeEach ->
      @session.save
        name: "Dead Man"
        session: "1234abcd-xxxx"
        login: "deadman"
    
    it "is triggered by errors on connections", ->
      @session.onUnauthorized = sinon.spy()
      @session.initialize()
      @session.connections.trigger "error:403"
      @session.onUnauthorized.should.have.been.calledOnce

    it "clears session ", ->
      @session.onUnauthorized()
      expect(@session.get "token").to.not.exist

    it "triggers event", ->
      spy = sinon.spy()
      @session.on "unauthorized", spy
      @session.onUnauthorized()
      spy.should.have.been.calledOnce

  describe "#destroy", ->
    
    it "destroys notifications", ->
      @session.notifications.destroy = sinon.spy()
      @session.destroy()
      @session.notifications.destroy.should.have.been.calledOnce
      
    it "destroys connections", ->
      @session.connections.destroy = sinon.spy()
      @session.destroy()
      @session.connections.destroy.should.have.been.calledOnce

    it "clears storage", ->
      @session.save
        name: "Dead Man"
        session: "1234abcd-xxxx"
        login: "deadman"
      @session.destroy()
      expect(localStorage.getItem "name").to.be.null
      expect(localStorage.getItem "token").to.be.null
      expect(localStorage.getItem "login").to.be.null
